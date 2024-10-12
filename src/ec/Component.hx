package ec;
import ec.IComponent;
import ec.Entity;

@:autoBuild(ec.macros.InitMacro.build())
class Component implements IComponent {
    @:isVar public var entity(get, set):Entity;

    public function new(e:Entity = null) {
        // todo dirty hack: for unknown reasons using getOrCreate() macro for subclasses causes 'ec.Entity has no field onContext'
        // extract minimal repro and create an issue or fix the cause
        if(false)
            trace(entity?.onContext);
        set_entity(e);
    }

    function _init(e:Entity) {}

    public function init() {}

    public function get_entity():Entity {
        return entity;
    }

    public function set_entity(entity:Entity):Entity {
        if (this.entity != null)
            this.entity.onContext.remove(_init);
        this.entity = entity;
        if (this.entity != null) {
            entity.onContext.listen(_init);
            _init(entity);
        }
        return entity;
    }
}