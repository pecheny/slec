package ec.macros;
//#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.ComplexType;
class MacroUtils {
//    #if macro


    public macro static function defClass<T>(e:ExprOf<Class<T>>):ExprOf<String> {
        trace(e);
        return macro "foo";
    }
//    #else
//
//    public static function getComponentId(c:Any):String {
//        return "fc";
//    }
//    #end

}
