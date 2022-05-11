package ec.macros;
import haxe.macro.Context;
import haxe.macro.Expr;
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
                // case {name:name, kind:FVar(ct), meta: [{name: ":listen"}]}:
                //     switch ct {
                //         case TPath({name:typeName, pack:[]}):
                //             initListen[name] = typeName;
                //         case _:throw "Wrong type to inject" + ct;
                //     }
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
            trace(injection);
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
