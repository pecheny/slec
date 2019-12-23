package ec;
@:forward(remove)
abstract Signal<T:haxe.Constraints.Function>(Array<T>) {
    public inline function new() this = [];

    public inline function listen(listener:T) this.push(listener);
    public macro function dispatch(signal, args:Array<haxe.macro.Expr>) {
        return macro for (listener in $signal.asArray()) listener($a{args});
    }
    public inline function asArray() return this;
}
