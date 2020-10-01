package ec;
class CtxBinder<T:CtxBindable> {
    var cl:Class<T>;
    var ctx:T;
    var entity:Entity;
    var upwardOnly:Bool;
    public function new (cl:Class<T>, e:Entity, upwardOnly = false) {
        this.upwardOnly = upwardOnly;
        this.cl = cl;
        this.entity = e;
        entity.onContext.listen(onContext);
    }

    function onContext(e:Entity) {
        if (ctx != null)
            ctx.unbind(entity);
        if (!upwardOnly)
            ctx = entity.getComponentUpward(cl);
        else if(entity.parent != null)
            ctx = entity.parent.getComponentUpward(cl);
        else
            ctx = null;
        if (ctx == null) {
            return;
        }
        ctx.bind(entity);
    }

}

interface CtxBindable {
    function bind(e:Entity):Void;
    function unbind(e:Entity):Void;
}

