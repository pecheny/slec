package ec;
class CtxWatcher<T:CtxBinder> {
    var cl:Class<T>;
    var ctx:T;
    var entity:Entity;
    var upwardOnly:Bool;

    public function new(cl:Class<T>, e:Entity, upwardOnly = false) {
        var alias = getComponentName(cl);
        if (e.hasComponentWithName(alias)) {
            var b = e.getComponentByName(alias);
            if (upwardOnly != @:privateAccess b.upwardOnly)
                throw "Combination of CtxWatcher with different upwardOnly property is not supported yet,";
            @:privateAccess b.onContext(e);
            return;
        }
        e.addComponentByName(alias, this);
        this.upwardOnly = upwardOnly;
        this.cl = cl;
        this.entity = e;
        entity.onContext.listen(onContext);
        onContext(e.parent);
    }

    function getComponentName(cl:Class<T>) {
        return "ctxbinder_" + Entity.getComponentId(cl);
    }

    function onContext(e:Entity) {
        if (ctx != null)
            ctx.unbind(entity);
        if (!upwardOnly)
            ctx = entity.getComponentUpward(cl);
        else if (entity.parent != null)
            ctx = entity.parent.getComponentUpward(cl);
        else
            ctx = null;
        if (ctx == null) {
            return;
        }
        ctx.bind(entity);
    }

    public function unbind() {
        if (ctx != null)
            ctx.unbind(entity);
    }

    public function rebind() {
        if (ctx != null)
            ctx.bind(entity);
    }

}

interface CtxBinder {
    function bind(e:Entity):Void;

    function unbind(e:Entity):Void;
}

