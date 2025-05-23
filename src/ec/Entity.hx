package ec;

import haxe.ds.ReadOnlyArray;
import Type;

class Entity {
    var children:Array<Entity> = [];

    public var parent(default, null):Entity;
    public var name = "";

    /**
     * The signal dispatches to entity and all their children hierarchy after it been added to parent
    **/
    public var onContext(default, null):Signal<Entity->Void> = new Signal();

    public function new(n = "") {
        this.name = n;
    }

    @:access(Entity.parent)
    public function addChild(e:Entity) {
        if (this == e)
            throw "You do not want add entity to themself as a child";
        if (e.parent != null)
            e.parent.removeChild(e);
        e.parent = this;
        children.push(e);
        e.dispatchContext(this);
    }

    public function dispatchContext(e:Entity = null) {
        if (e == null)
            e = this;
        #if !macro
        onContext.dispatch(e);
        #end
        for (ch in children)
            ch.dispatchContext(e);
    }

    @:access(Entity.parent)
    public function removeChild(e:Entity) {
        if (e.parent != this)
            throw "Wrong";
        if (children.indexOf(e) < 0)
            throw "Wrong";
        e.parent = null;
        children.remove(e);
        e.dispatchContext(null);
    }

    var components:Map<String, Any> = new Map();

    public inline function getChildren():ReadOnlyArray<Entity> {
        return children;
    }

    /**
     * Looks for child by given path represented as array where element means index of entity at given depth. I. e.
     * e.getGrandchild([1,2]) is equivalent for egetChildren()[1].getChildren()[2].
    **/
    public function getGrandchild(path:Array<Int>) {
        var id = path.shift();
        if (children.length > id) {
            var next = children[id];
            return if (path.length > 0) next.getGrandchild(path) else next;
        }
        return null;
    }

    public function addComponent<T>(c:T):T {
        var id = getComponentId(c);
        return addComponentByName(id, c);
    }

    static public function getComponentId(c:Dynamic):String {
        var id = switch c {
            case _ if (Std.isOfType(c, Class)): Type.getClassName(c);
            case _ if (Std.isOfType(c, ICustomComponentId)): cast(c, ICustomComponentId).getId();
            case _: Type.getClassName(Type.getClass(c));
        }
        return id;
    }

    /**
        Allows to add component related to other entity.
        Meant for routing deps between childern. Needs more design investigation.
    **/
    public function addAliasByName<T>(key:String, c:T):T {
        if (components.exists(key))
            throw 'Component $key already exists on this entity';
        components[key] = c;
        dispatchContext(this);
        return c;
    }

    /**
        Adds component by given key.
    **/
    public function addComponentByName<T>(key:String, c:T):T {
        if (components.exists(key))
            throw 'Component $key already exists on this entity';
        components[key] = c;
        if (Std.isOfType(c, IComponent))
            cast(c, IComponent).set_entity(this);
        dispatchContext(this);
        return c;
    }

    public function addComponentByType<T, Tc:T>(t:Class<T>, c:Tc):Tc {
        return addComponentByName(getComponentId(t), c);
    }

    public function removeComponentWithName(name:String) {
        if (!components.exists(name))
            throw "No component with name " + name;
        var c = components[name];
        if (Std.isOfType(c, IComponent))
            cast(c, IComponent).set_entity(null);
        if (!components.remove(name))
            throw "Wrong";
    }

    public function removeComponent<T>(cl:Class<T>) {
        var id = getComponentId(cl);
        removeComponentWithName(id);
    }

    public function getComponent<T>(cl:Class<T>):T {
        return cast getComponentByName(getComponentId(cl));
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

    public function getComponents():Array<String> {
        return [for (k in components.keys()) k];
    }

    /**
     * Returns first occurance of T component during search upward through hierarhy and starting from this entity.
     * If nothing found returns null.
    **/
    public function getComponentUpward<T>(cl:Class<T>):T {
        if (hasComponent(cl))
            return getComponent(cl);
        if (parent == null)
            return null;
        return parent.getComponentUpward(cl);
    }

    public function getComponentByNameUpward(name):Dynamic {
        if (hasComponentWithName(name))
            return getComponentByName(name);
        if (parent == null)
            return null;
        return parent.getComponentByNameUpward(name);
    }

    public function getOrCreate<T>(cl:Class<T>, fac:Void->T):T {
        var c = getComponent(cl);
        if (c != null)
            return c;
        c = fac();
        addComponent(c);
        addComponentByType(cl, c);
        return c;
    }

    /**
     *   Walks through hierarchy and calls given function for each entity with their path represented as array of indices
    **/
    public function traverse(h:(Entity, Array<String>) -> Void, path:Array<String>) {
        h(this, path);
        var id = "" + if (parent != null) parent.getChildren().indexOf(this) else -1;
        path.push(id);
        for (c in children)
            c.traverse(h, path);
        path.pop();
    }

    public function findFirstInside<T>(cl:Class<T>):T {
        var selfComp = getComponent(cl);
        if (selfComp != null)
            return selfComp;
        for (ch in children) {
            var compOnChild = ch.findFirstInside(cl);
            if (compOnChild != null)
                return compOnChild;
        }
        return null;
    }

    public function toString() {
        return '[Entity $name]';
    }

    public function getPath() {
        var r = name;
        if (parent != null)
            r = parent.getPath() + " / " + r;
        return r;
    }

    public macro function addTypedef<T:{}>(ethis, t:ExprOf<T>, ?aliasExpr = null) {
        var ttype = haxe.macro.Context.typeof(t);
        switch ttype {
            case TType(_.get() => tt, params):
                var typeName = haxe.macro.TypeTools.toString(ttype);
                var nameExpr = switch aliasExpr {
                    case macro null: macro $v{typeName};
                    case _: macro $v{typeName} + "_" + $aliasExpr;
                }
                return macro $ethis.addComponentByName($nameExpr, $t);
            case _:
                throw 'Not a typedef instance passed as  e.addTypedef() argument: $t';
        }
    }

    /**
     *  Adds component with key composed by type and name to use with @:once(name)
    **/
    #if !display
    public macro function addNamedComponent<T>(ethis, etype, name, c):ExprOf<T> {
        var s1 = ec.macros.Macros.checkType(etype);
        var str = macro $v{s1} + "_" + $name;
        return macro $ethis.addComponentByName($str, $c);
    }
    #else
    public function addNamedComponent<T>(etype:Dynamic, name:String, c:T):T
        throw "for completion only";
    #end
}
