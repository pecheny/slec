package ec;

import ec.EntityHolder;
import ec.Entity;
import ec.Signal;

interface Flag {
    public var enabled(get, set):Bool;
}

@:autoBuild(ec.macros.Macros.buildFlagCompo())
class FlagComponent extends EntityHolder {
    public var onChange(default, null):Signal<Bool->Void> = new Signal();
    @:isVar public var enabled(get, set):Bool;

    function get_enabled():Bool {
        return enabled;
    }

    function set_enabled(value:Bool):Bool {
        enabled = value;
        onChange.dispatch(value);
        return value;
    }

    function new() {}

    public function bind(e:Entity) {
        e.addComponent(this);
    }
}
