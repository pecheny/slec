package ec.macros;

import haxe.macro.Expr;
import haxe.macro.Context;

#if macro
class Macros {
    public static function buildFlagCompo() {
        var ct = Context.getLocalClass().get();
        var ttp = @:privateAccess haxe.macro.TypeTools.toTypePath;
        var tp:TypePath = ttp(ct, []);
        var typeExpr:Expr = macro $i{ct.name}; // {expr:EConst(CIdent(ct.name)), pos:Context.currentPos()};
        var body = macro {
            var tg = e.getComponent($typeExpr);
            if (tg != null)
                return tg;
            tg = new $tp();
            tg.bind(e);
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
}
#end
