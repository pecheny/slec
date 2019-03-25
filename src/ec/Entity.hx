package ec;
class Entity {
    var children:Array<Entity> = [];
    public var parent(default, null):Entity;

    public function new() {
    }

    @:access(Entity.parent)
    public function addChild(e:Entity) {
        if (e.parent != null)
            e.parent.removeChild(e);
        e.parent = this;
        children.push(e);
    }

    @:access(Entity.parent)
    public function removeChild(e:Entity) {
        if (e.parent != this)
            throw "Wrong";
        if (children.indexOf(e) < 0)
            throw "Wrong";
        e.parent = null;
        children.remove(e);
    }

    var components:Map<String, Component> = new Map();


    public function addComponent<T:Component>(c:T):T {
        if (components.exists(c.type))
            throw "Wrong";
        components[c.type] = c;
        c.entity = this;
        return c;
    }

    public function removeComponent(type) {
        if (!components.exists(type))
            throw "Wrong";
        var c = components[type];
        c.entity = null;
        if (!components.remove(type))
            throw "Wrong";
    }

    public function getComponent(type) {
        if (components.exists(type))
            return components[type];
        if (parent != null)
            return parent.getComponent(type);
        return null;
    }

    public function getComponentSelf(type):Dynamic {
        if (components.exists(type))
            return components[type];
        return null;
    }
}
@:allow(ec.Entity)
class Component {
    public var type(default, null):String;
    public var entity(default, null):Entity;

    public function new(type) {
        this.type = type;
    }
}

