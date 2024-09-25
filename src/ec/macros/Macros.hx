package ec.macros;

import haxe.macro.Expr;
import haxe.macro.Context;

#if macro
class Macros {
    public static function buildGetOrCreate(?onCreate:String) {
        var ct = Context.getLocalClass().get();
        var ttp = @:privateAccess haxe.macro.TypeTools.toTypePath;
        var tp:TypePath = ttp(ct, []);
        var typeExpr:Expr = macro $i{ct.name}; // {expr:EConst(CIdent(ct.name)), pos:Context.currentPos()};

        var bindCall = if (onCreate == null) macro e.addComponent(tg) else macro tg.$onCreate(e);
        var body = macro {
            var tg = e.getComponent($typeExpr);
            if (tg != null)
                return tg;
            tg = new $tp();
            $bindCall;
            return tg;
        };

        var f:Field;
        var fields = Context.getBuildFields();
        fields.push({
            name: "getOrCreate",
            access: [APublic, AStatic],
            kind: FFun({
                args: [
                    {
                        name: "e",
                        type: macro :ec.Entity
                    }
                ],
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
