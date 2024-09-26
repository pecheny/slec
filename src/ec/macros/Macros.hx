package ec.macros;

import haxe.macro.Type.TFunc;
import haxe.macro.Type.ClassType;
import haxe.macro.Expr;
import haxe.macro.Context;

using haxe.macro.TypeTools;

#if macro
class Macros {
    public static function buildGetOrCreate(?onCreate:String) {
        function findCtr(ct:ClassType) {
            if (ct.constructor != null)
                return ct.constructor.get();
            if (ct.superClass != null) {
                return findCtr(ct.superClass.t.get());
            }
            return null;
        }

        function extractCtrArgs() {
            var fields = Context.getBuildFields();
            for (f in fields) {
                if (f.name == "new")
                    switch f.kind {
                        case FFun(f):
                            return f.args.map(a -> {name: a.name, type: a.type});
                        case _:
                            throw "wrong";
                    }
            }

            var ctrArgs = switch findCtr(Context.getLocalClass().get())?.type.follow() {
                case TFun(args, ret): args.map(a -> {name: a.name, type: a.t.toComplexType()});
                case _: null;
            }
            if (ctrArgs != null)
                return ctrArgs;
            throw "Magic, there is no constrictor ";
        }

        var ct = Context.getLocalClass().get();
        var fields = Context.getBuildFields();
        var ctrArgs = extractCtrArgs();

        var ttp = @:privateAccess haxe.macro.TypeTools.toTypePath;
        var tp:TypePath = ttp(ct, []);
        var typeExpr:Expr = macro $i{ct.name}; // {expr:EConst(CIdent(ct.name)), pos:Context.currentPos()};

        var bindCall = if (onCreate == null) macro e.addComponent(tg) else macro tg.$onCreate(e);
        var body = macro {
            var tg = e.getComponent($typeExpr);
            if (tg != null)
                return tg;
            tg = new $tp($a{ctrArgs.map(a -> macro $i{a.name})});
            $bindCall;
            return tg;
        };

        fields.push({
            name: "getOrCreate",
            access: [APublic, AStatic],
            kind: FFun({
                args: [
                    {
                        name: "e",
                        type: macro :ec.Entity
                    }
                ].concat(ctrArgs),
                expr: body
            }),
            pos: Context.currentPos()
        });
        return fields;
    }

    public static function checkType(e) {
        return switch e.expr {
            case EConst(CIdent(s)):
                var t = Context.getType(s); // check if there is a type with given name, typo guard
                s;
            case _:
                throw "Wrong type ";
        };
    }
}
#end
