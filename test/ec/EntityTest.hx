package ec;
import utest.Assert;
import utest.Assert.isTrue as assert;
import utest.Test;
import ec.Entity;
class EntityTest extends Test {

    function test_add_remove_arbitrary_instance() {
        var c = new Cmp();
        var e = new Entity();
        e.addComponent(c);
        var c2 = e.getComponent(Cmp);
        assert(e.hasComponent(Cmp));
        Assert.equals(c, c2);
        e.removeComponent(Cmp);
        assert((!e.hasComponent(Cmp)));
    }

    function test_add_remove_typedef() {
        var c = new CmpDef();
        var e = new Entity();
        e.addComponent(c);
        var c2 = e.getComponent(Cmp);
        assert(e.hasComponent(Cmp));
        Assert.equals(c, c2);
        e.removeComponent(Cmp);
        assert((!e.hasComponent(Cmp)));
    }

    function test_IComponent() {
        var c = new CmpWEnt();
        var e = new Entity();
        e.addComponent(c);
        var c2:CmpWEnt = e.getComponent(CmpWEnt);
        assert(e.hasComponent(CmpWEnt));
        Assert.equals(c, c2);
        Assert.equals(c2.entity, e);
        e.removeComponent(CmpWEnt);
        assert((c2.entity == null));
        assert(!e.hasComponent(CmpWEnt));
    }

    function test_custom_component_id() {
        var name = "name";
        var c = new NamedCmp(name);
        var e = new Entity();
        e.addComponent(c);
        var c2:NamedCmp = e.getComponentByName(name);
        assert(!e.hasComponent(NamedCmp));
        Assert.equals(c, c2);
        e.removeComponentWithName(name);
        assert(!e.hasComponentWithName(name));
    }

    function test_getUpward() {
        var root = new Entity();
        var tc = new TestComponent();
        root.addComponent(tc);
        var ch1 = new Entity();
        var ch2 = new Entity();
        root.addChild(ch1);
        ch1.addChild(ch2);
        Assert.equals(tc, ch1.getComponentUpward(TestComponent));
        Assert.equals(tc, ch2.getComponentUpward(TestComponent));
        var tc2 = new TestComponent();
        ch1.addComponent(tc2);
        Assert.equals(tc2, ch1.getComponentUpward(TestComponent));
        Assert.equals(tc2, ch2.getComponentUpward(TestComponent));
    }

    function test_getGrandChild() {
        var root = new Entity();
        var ch1 = new Entity();
        var ch2 = new Entity();
        var ch1_1 = new Entity();
        var ch2_1 = new Entity();
        var ch1_2 = new Entity();
        var ch2_2 = new Entity();

        root.addChild(ch1);
        root.addChild(ch2);
        ch1.addChild(ch1_1);
        ch1.addChild(ch1_2);
        ch2.addChild(ch2_1);
        ch2.addChild(ch2_2);

        Assert.equals(ch1_1, root.getGrandchild([0, 0]));
        Assert.equals(ch2_2, root.getGrandchild([1, 1]));
        Assert.equals(ch2, root.getGrandchild([1]));
    }

    // traverse

    // ? utils
}
class TestComponent {
    public function new() {}
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
