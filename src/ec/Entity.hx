package ec;
import Type;
import ec.Component;
import ec.macros.MacroUtils;
#if macro
import haxe.macro.Expr;
#end
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


    /**
    * (?) инлайнить ключ типа на основе получееного инстанса. макро метод, в котором нужно получить ссылку на имя типа.
    * макро-функция получает экспрешн, поэтому функция должна быть не макро.
    * или же аддЦомпонент тоже макро.
**/

    public function addComponentPrim<T>( c:T):T {
        var id = getComponentId(c);
        trace(id);
        return addComponentInternal(id, c);
//        var key = MacroUtils.getComponentId(c)

    }
    static function getComponentId(c:Dynamic):String {
        var id = switch c {
            case _ if (Std.is(c, Class)) :   Type.getClassName(c);
            case _ if (Std.is(c, ICustomComponentId)) :  cast(c, ICustomComponentId).getId();
            case _ :  Type.getClassName(Type.getClass(c));
        }
        return id;
    }
    public function addComponentInternal<T>(key:String, c:T):T {
        if (components.exists(key))
            throw 'Component $key already exists on this entity';
        components[key] = c;
//        c.entity = this;
        return c;
    }

    public function removeComponent<T>(cl:Class<T>) {
        var id = getComponentId(cl);
        if (!components.exists(id))
            throw "Wrong";
        var c = components[id];
//        c.entity = null;
        if (!components.remove(id))
            throw "Wrong";
    }

    public function getComponent<T>(cl:Class<T>):T {
        return getComponentByName(cl, getComponentId (cl));

//        trace("" + clexp);
//        return macro cast $ethis.components["1"];
//        if (components.exists(type))
//            return components[type];
//        if (parent != null)
//            return parent.getComponent(type);
//        return null;
    }

    public inline function getComponentByName<T>(cl:Class<T>, name:String):T {
        var next = components.keys().next();
        trace("'" + name  + "' '" + next  + "' " + (name == next));
        trace("Name: " + name  + " " + components.exists(name)  + " " + next);
        var c = components[name];
//        if (Std.is(c, T))
            return cast c;
//        else
//            throw "Wrong type of component " + c;
    }

    public function hasComponent<T>(cl:Class<T>):Bool {
        return components.exists(getComponentId(cl));
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

