package ec;

import ec.EntityHolder;
import ec.Entity;
import ec.Signal;

interface Flag {
    public var enabled(get, set):Bool;
}

@:autoBuild(ec.macros.Macros.buildGetOrCreate())
class PropertyComponent<T> extends EntityHolder {
    public var onChange(default, null):Signal<Void->Void> = new Signal();
    @:isVar public var value(get, set):T;

    function get_value():T {
        return value;
    }

    function set_value(value:T):T {
        this.value = value;
        onChange.dispatch();
        return value;
    }

    function new() {}

    public function bind(e:Entity) {
        e.addComponent(this);
    }
}

class FlagComponent extends PropertyComponent<Bool> implements Flag {
    public var enabled(get, set):Bool;

    function get_enabled():Bool {
        return value;
    }

    function set_enabled(value:Bool):Bool {
        return this.value = value;
    }
}
