package ec;

class CtxWatcher<T:CtxBinder> extends CtxWatcherBase<T> {
    public function new(cl:Class<T>, e:Entity, upwardOnly = false, verbose = false) {
        var alias = Entity.getComponentId(cl);
        super(alias, e, upwardOnly, verbose);
    }
}

class CtxWatcherBase<T:CtxBinder> {
    var cl:String;
    var ctx:T;
    var entity:Entity;
    var upwardOnly:Bool;
    var verbose:Bool;

    public function new(cl, e:Entity, upwardOnly = false, verbose = false) {
        var alias = getComponentName(cl);
        this.verbose = verbose;
        if (verbose)
            trace("watcher created");
        if (e.hasComponentWithName(alias)) {
            var b = e.getComponentByName(alias);
            if (upwardOnly != @:privateAccess b.upwardOnly)
                throw "Combination of CtxWatcher with different upwardOnly property is not supported yet,";
            @:privateAccess b.onContext(e);
            return;
        }
        this.cl = cl;
        this.entity = e;
        e.addComponentByName(alias, this);
        this.upwardOnly = upwardOnly;
        entity.onContext.listen(onContext);
        onContext(e.parent);
    }

    function getComponentName(alias) {
        return "ctxbinder_" + alias;
    }

    function onContext(e:Entity) {
        if (verbose)
            trace("onContext" + entity.name);
        if (ctx != null)
            ctx.unbind(entity);
        if (!upwardOnly)
            ctx = entity.getComponentByNameUpward(cl);
        else if (entity.parent != null)
            ctx = entity.parent.getComponentByNameUpward(cl);
        else
            ctx = null;
        if (ctx == null) {
            return;
        }
        if (verbose)
            trace("binding " + entity.name);
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
