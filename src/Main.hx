package ;
import ec.Entity;
import ec.ICustomComponentId;
class Main {
    public static function main() {
        var e = new Entity();
        e.addComponentPrim(new Cmp());
        var c = e.getComponent(Cmp);
        trace("_-^ " + c);
        trace("\n\n arb");
        addRemoveCmpArb();
        trace("\n\n cm");
        addRemoveCmp();
        trace("\n\n name");
        addRemoveCmpName();
    }

    static function addRemoveCmpArb() {
        var c = new Cmp();
        var e = new Entity();
        e.addComponentPrim(c);
        var c2 = e.getComponent(Cmp);
        trace("Component = " + c);
        assert(e.hasComponent(Cmp), "has");
        assert((c == c2), "eq");
        e.removeComponent(Cmp);
        assert((!e.hasComponent(Cmp)), "has not");
    }

    static function addRemoveCmp() {
        var c = new CmpWEnt();
        var e = new Entity();
        e.addComponentPrim(c);
        var c2:CmpWEnt = e.getComponent(CmpWEnt);
        trace("Component = " + c2);
        assert(e.hasComponent(CmpWEnt), "has");
        assert((c == c2), "eq");
        assert((c2.entity == e), "ent : " + c2.entity);
        e.removeComponent(CmpWEnt);
        assert((!e.hasComponent(CmpWEnt)), "has not");
    }

    static function addRemoveCmpName() {
        var name = "name";
        var c = new NamedCmp(name);
        var e = new Entity();
        e.addComponentPrim(c);
        var c2:NamedCmp = e.getComponentByName(NamedCmp, name);
        trace("Component = " + c2);
        assert(e.hasComponent(NamedCmp), "has / should fail");
        assert((c == c2), "eq");
//        assert((c2.entity == e), "ent");
//        e.removeComponent(NamedCmp);
        assert((!e.hasComponent(NamedCmp)), "has not");
    }

    static function assert(value:Bool, warn:String) {
        if (!value)
            trace("Failed: " + warn);
//        else
//            trace("Passed: " + warn);
    }
}
class Cmp {
    public function new() {}
}

class CmpWEnt {// implements IComponent {
    @:isVar public var entity(get, set):Entity;

    function get_entity():Entity {
        return entity;
    }

    function set_entity(value:Entity):Entity {
        return this.entity = value;
    }

    public function new() {}
}

class NamedCmp implements ICustomComponentId {
    var name:String;

    public function new(name:String) {
        this.name = name;
    }

    public function getId():String {
        return name;
    }

}
