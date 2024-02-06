package ec;

class EntityHolder implements IComponent {
    @:isVar public var entity(get, set):Entity;

    public function get_entity():Entity {
        return entity;
    }

    public function set_entity(value:Entity):Entity {
        return this.entity = value;
    }
}

class MultiparentEntityHolder {
    public var mpe(default, null):MultiparentEntity;

    public var entity(get, null):Entity;

    public function get_entity():Entity {
        return mpe;
    }

    public function set_entity(value:Entity):Entity {
        return this.entity = value;
    }

    public function setEntity(e:MultiparentEntity) {
        return mpe = e;
    }
}
