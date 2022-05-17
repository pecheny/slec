package ec.macros;
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

    public static function build():Array<Field> {
        var fields = Context.getBuildFields();
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

        var totalListeners = Lambda.count(initOnce);
        if (totalListeners == 0)
            return fields;

        fields.push({
            pos: Context.currentPos(),
            name: "_inited",
            kind: FieldType.FVar(macro : Bool, macro false),
        });

        initExprs.push(macro var listenersCount = $v{totalListeners});

        for (name in initOnce.keys()) {
            var injection = initOnce[name];
            if (injection.alias != null) {
                var alias = injection.type + "_" + injection.alias;
                initExprs.push(macro if ($i{name}== null) {
                    $i{name} = entity.getComponentByNameUpward($v{alias});
                });
            } else {
                initExprs.push(macro if($i{name}== null) {
                    $i{name} = entity.getComponentUpward($i{injection.type});
                });
            }


            initExprs.push(macro 
            if($i{name}!= null) {
                listenersCount--;
            });
        }

        initExprs.push(macro 
        if (listenersCount == 0) {
            entity.onContext.remove(_init);
            if(_inited)
                return;
            _inited = true;
            init();
        });


        if (initMethod == null) {
            initMethod = {
                access:[AOverride],
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
