package ec.macros;

#if macro
import haxe.CallStack;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type.ClassType;
#end

using haxe.macro.ComplexTypeTools;

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
    #if macro
    static var template = macro class Templ {
        var sources:Array<ec.Entity> = [];
        var _inited:Bool = false;
        public var _verbose:Bool = false;

        public function watch(e) {
            if (_inited)
                return;
            sources.push(e);
            e.onContext.listen(_init);
            e.dispatchContext(e);
        }

        function unsubscribe() {
            if (sources == null)
                return;
            for (e in sources)
                e.onContext.remove(_init);
            sources = null;
        }

        public function init() {}

        function _init(e:ec.Entity) {}
    }

    static function hasField(name) {
        var fields = Context.getBuildFields();
        for (f in fields)
            if (f.name == name)
                return true;
        var lc = Context.getLocalClass().get();
        return _hasField(lc, name);
    }

    static function _hasField(ct:ClassType, name) {
        for (f in ct.fields.get())
            if (f.name == name) {
                return true;
            }
        if (ct.superClass != null) {
            var r = _hasField(ct.superClass.t.get(), name);
            return r;
        }
        return false;
    }

    static function addField(fields:Array<Field>, name, type, ?e) {
        if (!hasField(name))
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
        if (_hasField(Context.getLocalClass().get(), name)) {
            access = [AOverride];
            exprs.unshift(macro $p{["super", name]}($a{args.map(ar -> macro $i{ar.name})}));
        }
        fields.push({
            pos: Context.currentPos(),
            name: name,
            access: access,
            kind: FieldType.FFun({args: args, expr: {expr: EBlock(exprs), pos: Context.currentPos()}}),
        });
    }

    static function addCountAndResolveDepsMethod(fields:Array<Field>, initOnce:Map<String, InjDescr>) {
        var name = "_countAndResolveDeps";
        for (f in fields)
            if (f.name == name)
                return;
        var initExprs = [];
        var debugExprs = [macro if (_inited) return, macro trace(this, [for (e in sources) "e: " + e.name  + " Path: " +  e.getPath()])];
        var totalListeners = Lambda.count(initOnce);
        if (_hasField(Context.getLocalClass().get(), name)) {
            initExprs.push(macro _depsCount += $v{totalListeners});
        } else {
            addField(fields, "_depsCount", macro :Int, macro 0);
            initExprs.push(macro _depsCount = $v{totalListeners});
        }

        initExprs.push(macro if (e == null) return);

        for (name in initOnce.keys()) {
            var injection = initOnce[name];
            initExprs.push(macro var wasNull = $i{name} == null);

            var searchByName = injection.alias != null || injection.isTypedef;
            if (searchByName) {
                var alias = injection.type;
                if (injection.alias != null)
                    alias += "_" + injection.alias;
                initExprs.push(macro if ($i{name} == null) {
                    $i{name} = e.getComponentByNameUpward($v{alias});
                });
            } else {
                initExprs.push(macro if ($i{name} == null) {
                    $i{name} = e.getComponentUpward($i{injection.type});
                });
            }

            initExprs.push(macro if ($i{name} != null) {
                if (_verbose && wasNull) {
                    trace($i{name} + " assigned " + _depsCount);
                }
                _depsCount--;
                if (_verbose)
                    trace(this, $i{name}, $v{name}, '$_depsCount remains');
            });
            
            debugExprs.push(macro trace($v{name}, ": ", $i{name}));
        }
        addMethod(fields, "_countAndResolveDeps", initExprs, [
            {
                name: "e",
                opt: false,
                meta: [],
                type: TPath({pack: ['ec'], name: 'Entity'})
            }
        ]);
        
        #if debug
        addMethod(fields, "_debugState", debugExprs, [ ]);
        #end

    }

    public static function build():Array<Field> {
        var fields = Context.getBuildFields();
        #if display
        return fields;
        #end
        var lc = Context.getLocalClass().get();
        if (lc.isInterface)
            return fields;
        for (f in template.fields) {
            if (!hasField(f.name))
                fields.push(f);
        }
        var pos = Context.currentPos();
        var initFun;

        var initOnce:Map<String, InjDescr> = new Map();
        var initMethod;
        var initExprs = [];
        var ctxExprs = [];

        for (f in fields) {
            switch f {
                case {name: '_init', kind: FFun({args: [{name: en}], expr: {expr: EBlock(ie)}})}:
                    {
                        initMethod = f;
                        initExprs = ie;
                    }
                case {name: name, kind: FVar(ct), meta: [{name: ":once", params: prms}]}:
                    {
                        var alias = switch prms {
                            case [{expr: EConst(CString(alias, _))}]: alias;
                            case []: null;
                            case _: throw "Wrong meta";
                        }
                        switch ct {
                            case TPath({name: typeName, pack: []}):
                                var isTypedef = switch ct.toType() {
                                    case TType(_, _): true;
                                    case _: false;
                                }
                                 initOnce[name] = 
                                    if (isTypedef)
                                        {type: typeToString(ct.toType()), alias: alias, isTypedef:true};
                                    else
                                        {type: typeName, alias: alias, isTypedef:false};
                            case _: throw "Wrong type to inject" + ct;
                        }
                    }
                case {name: 'new', kind: FFun({ expr: {expr: EBlock(ie)}})}:
                    ctxExprs = ie;

                case _:
            }
        }

        initExprs.unshift(macro if (_verbose) trace("init called " + this, e, e?.getPath() /*, "\n",haxe.callstack.tostring(haxe.callstack.callstack ())*/));


        var totalListeners = Lambda.count(initOnce);
        if (totalListeners == 0)
            return fields;

        //        addMethod(fields,"_showDeps", [for(n in initOnce.keys()) macro if ($i{n} == null) trace($v{n} + " " + $i{n})]);
        addCountAndResolveDepsMethod(fields, initOnce);

        initExprs.push(macro _countAndResolveDeps(e));
        initExprs.push(macro if (_depsCount == 0) {
            if (_inited)
                return;
            unsubscribe();
            _inited = true;
            if (_verbose) {
                trace(this, "_init done, calling init()\n\n");
                trace(e, e.getPath());
            }
            init();
        });

        #if debug
        ctxExprs.push(macro ec.DebugInit.initCheck.listen(_debugState) );
        #end

        if (initMethod == null) {
            initMethod = {
                access: _hasField(Context.getLocalClass().get(), "_init") ? [AOverride] : [],
                name: '_init',
                kind: FFun({
                    args: [
                        {
                            name: "e",
                            opt: false,
                            meta: [],
                            type: TPath({pack: ['ec'], name: 'Entity'})
                        }
                    ],
                    expr: {expr: EBlock(initExprs), pos: pos},
                    ret: null
                }),
                pos: pos
            };
            fields.push(initMethod);
        }

        return fields;
    }
    #end

    static function typeToString(tp:haxe.macro.Type) {
        switch tp {
            case TInst(t, params):
                return "" + t;
            case TType(t, params):
                return "" + t;
            case _:
                throw "Wrong";
        }
    }
}

typedef InjDescr = {type:String, ?alias:String, isTypedef:Bool}
