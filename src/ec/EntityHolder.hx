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
