package ;
import ec.Entity;
import ec.IComponent;
import ec.ICustomComponentId;
class Main {
    public static function main() {
        trace(" arb");
        addRemoveCmpArb();
        trace("cm");
        addRemoveCmp();
        trace("name");
        addRemoveCmpName();
        trace("typedef: ");
        addRemoveCmpTypedef();
        trace('Total assertion ${failed + passed}, $failed failed');
    }

    static function addRemoveCmpArb() {
        var c = new Cmp();
        var e = new Entity();
        e.addComponent(c);
        var c2 = e.getComponent(Cmp);
        assert(e.hasComponent(Cmp), "has");
        assert((c == c2), "eq");
        e.removeComponent(Cmp);
        assert((!e.hasComponent(Cmp)), "has not");
    }

    static function addRemoveCmpTypedef() {
        var c = new CmpDef();
        var e = new Entity();
        e.addComponent(c);
        var c2 = e.getComponent(CmpDef);
        assert(e.hasComponent(Cmp), "has");
        assert((c == c2), "eq");
        e.removeComponent(Cmp);
        assert((!e.hasComponent(Cmp)), "has not");
    }

    static function addRemoveCmp() {
        var c = new CmpWEnt();
        var e = new Entity();
        e.addComponent(c);
        var c2:CmpWEnt = e.getComponent(CmpWEnt);
        assert(e.hasComponent(CmpWEnt), "has");
        assert((c == c2), "eq");
        assert((c2.entity == e), "ent : " + c2.entity);
        e.removeComponent(CmpWEnt);
        assert((c2.entity == null), "ent : " + c2.entity);
        assert((!e.hasComponent(CmpWEnt)), "has not");
    }

    static function addRemoveCmpName() {
        var name = "name";
        var c = new NamedCmp(name);
        var e = new Entity();
        e.addComponent(c);
        var c2:NamedCmp = e.getComponentByName(name);
        assert(!e.hasComponent(NamedCmp), "has no by type");
        assert((c == c2), "eq");
        e.removeComponentWithName(name);
        assert((!e.hasComponentWithName(name)), "has not");
    }

    static var failed:Int = 0;
    static var passed:Int = 0;

    static function assert(value:Bool, warn:String) {
        if (!value) {
            trace("Failed: " + warn);
            failed++;
        } else {
            passed++;
        }
    }
}

typedef CmpDef = Cmp;
class Cmp {
    public function new() {}
}

class CmpWEnt implements IComponent {
    @:isVar public var entity(get, set):Entity;

    public function get_entity():Entity {
        return entity;
    }

    public function set_entity(value:Entity):Entity {
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
