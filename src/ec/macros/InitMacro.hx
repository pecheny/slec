package ec.macros;

import haxe.macro.Type.ClassType;
import haxe.macro.Context;
import haxe.macro.Expr;

/**
 * The purpose of this macro is to
 * build initialization boilerplate for components which depends on other components.
 * It generates body for _init() method which should be presented in a class you are @:autobuilding.
 * Also you should subscribe this _init() handler to onContext of the entity supposed to be a source of dependencies.
 * For each variable  annotated with @:once meta the _init() function will look for component of proper type in the entity hierarchy and assign it when found.
 * When all fields with @:once meta have values, the init() (do not confuse with _init()) will called. The init() method also should be presented in the class. It supposed to do the initialization which needs the dependencies and can be overridden in classes which extend autobuilded.
 * @:see InitMacroTest for usage example.
**/
class InitMacro {
    static var template = macro class Templ {
        var sources:Array<ec.Entity> = [];

        public function watch(e) {
            sources.push(e);
            e.onContext.listen(_init);
            e.dispatchContext(e);
        }

        function unsubscribe() {
            this.entity.onContext.remove(_init);
            if(sources == null)
                return;
            for (e in sources)
                e.onContext.remove(_init);
            sources = null;
        }
        public function init() {}
        function _init(e:ec.Entity){}
    }

    static function hasField(ct:ClassType, name) {
        for (f in ct.fields.get())
            if (f.name == name) {
                return true;
            }
        if (ct.superClass != null) {
            var r = hasField(ct.superClass.t.get(), name);
            return r;
        }
        return false;
    }

    static function addField(fields:Array<Field>, name, type, ?e) {
        if (!hasField(Context.getLocalClass().get(), name))
            fields.push({
                pos: Context.currentPos(),
                name: name,
                kind: FieldType.FVar(type, e),
            });
    }

    static function addMethod(fields:Array<Field>, name, exprs:Array<Expr>, args:Array<FunctionArg> = null) {
        var access = null;
        if (args == null)
            args = [];
        if (hasField(Context.getLocalClass().get(), name)) {
            access = [AOverride];
            exprs.unshift(macro $p{["super", name]}($a{args.map(ar -> macro $i{ar.name})}));
        }
        fields.push({
            pos: Context.currentPos(),
            name: name,
            access:access,
            kind: FieldType.FFun({args:args, expr:{expr:EBlock(exprs), pos:Context.currentPos()}}),
        });
    }

    static function addCountAndResolveDepsMethod(fields, initOnce:Map<String, { type:String, ?alias:String }> ) {
        var name = "_countAndResolveDeps";
        var initExprs = [];
        var totalListeners = Lambda.count(initOnce);
        if (hasField(Context.getLocalClass().get(), name)) {
            initExprs.push(macro _depsCount += $v{totalListeners});
        } else {
            addField(fields, "_depsCount", macro : Int, macro 0);
            initExprs.push(macro _depsCount = $v{totalListeners});
        }

        //        initExprs.push(macro var listenersCount = $v{totalListeners});

        for (name in initOnce.keys()) {
            var injection = initOnce[name];
            initExprs.push(macro var wasNull = $i{name} == null);
            if (injection.alias != null) {
                var alias = injection.type + "_" + injection.alias;
                initExprs.push(macro if($i{name}== null) {
                    $i{name} = e.getComponentByNameUpward($v{alias});
                });
            } else {
                initExprs.push(macro if($i{name}== null) {
                    $i{name} = e.getComponentUpward($i{injection.type});
                });
            }


            initExprs.push(macro
            if($i{name}!= null) {
                if (_verbose && wasNull) {
                    trace($i{name} + " assigned " + _depsCount);
                    //                    _showDeps();
                }
                _depsCount--;
            });
        }
        addMethod(fields, "_countAndResolveDeps", initExprs, [{name: "e", opt: false, meta: [], type: TPath({pack:['ec'], name:'Entity'})}]);
    }

    public static function build():Array<Field> {
        var fields = Context.getBuildFields();
        var lc = Context.getLocalClass().get();
        for (f in template.fields)
            if (!hasField(lc, f.name))
                fields.push(f);
        var pos = Context.currentPos();
        var initFun;

        var initOnce:Map<String, {
                type:String, ?alias:String
        }> = new Map();
        var initMethod;
        var initExprs = [];

        for (f in fields) {
            switch f {
                case {name:'_init', kind:FFun({args:[{name:en}], expr:{expr:EBlock(ie)}})}:{
                        initMethod = f;
                        initExprs = ie;
                    }
                case {name:name, kind:FVar(ct), meta: [{name: ":once", params: prms}]}:
                    {
                        var alias = switch prms {
                            case [ { expr: EConst(CString(alias, _))} ]:alias;
                            case []:null;
                            case _: throw "Wrong meta";
                        }
                        switch ct {
                            case TPath({name:typeName, pack:[]}):
                                initOnce[name] = {type:typeName, alias:alias};
                            case _:throw "Wrong type to inject" + ct;
                        }
                    }
                case _:
            }

        }
        initExprs.unshift(macro if (_verbose) trace("init called " + this));

        addField(fields, "_verbose", macro : Bool);

        var totalListeners = Lambda.count(initOnce);
        if (totalListeners == 0)
            return fields;


        //        var traceStatusExprs = ;

        addField(fields, "_inited", macro : Bool);
        //        addMethod(fields,"_showDeps", [for(n in initOnce.keys()) macro if ($i{n} == null) trace($v{n} + " " + $i{n})]);
        addCountAndResolveDepsMethod(fields, initOnce);

        initExprs.push(macro  _countAndResolveDeps(this.entity));
        initExprs.push(macro  if(e!=null) _countAndResolveDeps(e));
        initExprs.push(macro 
        if (_depsCount == 0) {
            unsubscribe();
            if (_inited)
                return;
            _inited = true;
            if (_verbose)
                trace("_init done, calling init()");
            init();
        });


        if (initMethod == null) {
            initMethod = {
                access: hasField(Context.getLocalClass().get(), "_init") ? [AOverride] : [],
                name:'_init',
                kind:FFun({
                    args: [{name: "e", opt: false, meta: [], type: TPath({pack:['ec'], name:'Entity'})}],
                    expr:{expr:EBlock(initExprs), pos:pos},
                    ret:null
                        }
                ),
                pos:pos
            } ;
            fields.push(initMethod);
        }

        return fields;
    }

}
