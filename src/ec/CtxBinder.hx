package ec;
class CtxBinder<T:CtxBindable> {
    var cl:Class<T>;
    var ctx:T;
    var entity:Entity;
    public function new (cl:Class<T>, e:Entity) {
        this.cl = cl;
        this.entity = e;
        entity.onContext.listen(onContext);
    }

    function onContext(e:Entity) {
        if (ctx != null)
            ctx.unbind(entity);
        ctx = entity.getComponentUpward(cl);
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

