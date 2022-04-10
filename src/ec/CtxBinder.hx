package ec;
class CtxBinder<T:CtxBindable> {
    var cl:Class<T>;
    var ctx:T;
    var entity:Entity;
    var upwardOnly:Bool;
    public function new (cl:Class<T>, e:Entity, upwardOnly = false) {
        var alias = getComponentName(cl);
        if (e.hasComponentWithName(alias)) {
            var b = e.getComponentByName(alias);
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
        return "ctxbinder_"+Entity.getComponentId(cl);
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

    public function unbind() {
        if (ctx != null)
            ctx.unbind(entity);
    }

    public function rebind() {
        if (ctx != null)
            ctx.bind(entity);
    }

}

//@:access(ec.CtxBinder)
//@:access(ec.Binders)
//class Binders {
//    var classMap:ObjectMap<Dynamic, CtxBinder<Dynamic>> = new ObjectMap();
//    function new () {}
//    public static function getBinding<T:CtxBindable>(e:Entity, cl:Class<T>, upwardOnly = false):CtxBinder<T> {
//        var binders:Binders;
//        if (e.hasComponent(Binders)) {
//            binders = e.getComponent(Binders);
//        } else {
//            binders = new Binders();
//            e.addComponent(binders);
//        }
//        if (binders.classMap.exists(cl)){
//            var binder:CtxBinder<T> = cast binders.classMap.get(cl);
//            if (binder.upwardOnly != upwardOnly)
//                throw "Already has binder with different 'upwardOnly' value";
//            return binder;
//        }
//        var binder = new CtxBinder<T>(cl, e, upwardOnly);
//        binders.classMap.set(cl, binder);
//        return binder;
//    }
//
//    public function unbindAll() {
//        trace("unbind all");
//        for (k in classMap.keys()) {
//            var bdr = classMap.get(k);
//            bdr.unbind();
//        }
//    }
//
//    public function rebindAll() {
//        for (k in classMap.keys()) {
//            var bdr = classMap.get(k);
//            bdr.rebind();
//        }
//    }
//}

interface CtxBindable {
    function bind(e:Entity):Void;
    function unbind(e:Entity):Void;
}

