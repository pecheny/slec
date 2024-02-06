package ec;

class MultiparentEntity extends Entity {
    var parents:Array<Entity> = [];

    public function addParent(e:Entity) {
        parents.push(e);
        e.onContext.listen(e -> onContext.dispatch(e));
    }

    override function getComponentUpward<T>(cl:Class<T>):T {
        var r = super.getComponentUpward(cl);
        if (r != null)
            return r;
        for (p in parents) {
            r = p.getComponentUpward(cl);
            if (r != null)
                return r;
        }
        return null;
    }
}
