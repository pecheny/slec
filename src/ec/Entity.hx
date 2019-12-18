package ec;
import haxe.ds.ReadOnlyArray;
import Type;
class Entity {
    var children:Array<Entity> = [];
    public var parent(default, null):Entity;

    public function new() {}

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

    var components:Map<String, Any> = new Map();

    public inline function getChildren():ReadOnlyArray<Entity> {
        return children;
    }

    public function addComponent<T>(c:T):T {
        var id = getComponentId(c);
        return addComponentByName(id, c);
    }

    static function getComponentId(c:Dynamic):String {
        var id = switch c {
            case _ if (Std.is(c, Class)) : Type.getClassName(c);
            case _ if (Std.is(c, ICustomComponentId)) : cast(c, ICustomComponentId).getId();
            case _ : Type.getClassName(Type.getClass(c));
        }
        return id;
    }

    public function addComponentByName<T>(key:String, c:T):T {
        if (components.exists(key))
            throw 'Component $key already exists on this entity';
        components[key] = c;
        if (Std.is(c, IComponent))
            cast(c, IComponent).set_entity(this);
        return c;
    }

    public function removeComponentWithName(name:String) {
        if (!components.exists(name))
            throw "No component with name " + name;
        var c = components[name];
        if (Std.is(c, IComponent))
            cast(c, IComponent).set_entity(null);
        if (!components.remove(name))
            throw "Wrong";
    }

    public function removeComponent<T>(cl:Class<T>) {
        var id = getComponentId(cl);
        removeComponentWithName(id);
    }

    public function getComponent<T>(cl:Class<T>):T {
        return cast getComponentByName( getComponentId(cl));
    }

    public inline function getComponentByName(name:String):Dynamic {
        return components[name];
    }

    public function hasComponent<T>(cl:Class<T>):Bool {
        return hasComponentWithName(getComponentId(cl));
    }

    public function hasComponentWithName(name) {
        return components.exists(name);
    }

    public function traverse(h:(Entity, Array<String>)->Void, path:Array<String>) {
        h(this, path);
        var id = "" +
        if (parent != null)
            parent.getChildren().indexOf(this)
        else
            -1;
        path.push(id);
        for (c in children)
            h(c, path);
        path.pop();
    }

}
//@:allow(ec.Entity)
//class Component {
//    public var type(default, null):String;
//    public var entity(default, null):Entity;
//
//    public function new(type) {
//        this.type = type;
//    }
//}

