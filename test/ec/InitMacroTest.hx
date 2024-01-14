package ec;

import utest.Assert;
import ec.Entity;

class InitMacroTest extends utest.Test {
    public function test_init_once() {
        var root = new Entity();
        var c1 = new Obj();
        var c2 = new Obj("named");
        root.addComponent(c1);
        root.addComponentByName("Obj_named", c2);

        var tester = new InjectionTester();

        root.addChild(tester.entity);
        Assert.equals(c1, tester.obj, "Test @:once injection");
        Assert.equals(c2, tester.named, "Test named injection");
    }
    public function test_all_deps_with_inheritance() {
        var root = new Entity();
        var c1 = new Obj();
        var c2 = new Obj("named");
        root.addComponent(c1);
        root.addComponentByName("Obj_named", c2);

        var tester = new ExtendedINjectionTester();

        root.addChild(tester.entity);
        Assert.equals(0, tester.initCalls);
        Assert.equals(null, tester.other, "Test @:once injection");
        Assert.equals(c2, tester.named, "Test named injection");

        root.addComponentByName("Obj_otherNamed", c2);

        Assert.equals(1, tester.initCalls);
        Assert.equals(c2, tester.other, "Test @:once injection");

    }
    public function test_all_deps_with_inheritance_reverse_init_order() {
        var root = new Entity();
        var c1 = new Obj();
        var c2 = new Obj("named");
        root.addComponent(c1);
        root.addComponentByName("Obj_otherNamed", c2);
        var tester = new ExtendedINjectionTester();

        root.addChild(tester.entity);
        Assert.equals(0, tester.initCalls);
        Assert.equals(c2, tester.other, "Test @:once injection");
        root.addComponentByName("Obj_named", c2);

        Assert.equals(1, tester.initCalls);
        Assert.equals(c2, tester.named, "Test named injection");
    }
}
class ExtendedINjectionTester extends InjectionTester {
    @:once("otherNamed")public var other:Obj;
    public var initCalls = 0;
    override public function init() {
        initCalls++;
    }
}

@:autoBuild(ec.macros.InitMacro.build()) class MacroBaseClass {}

class InjectionTester extends MacroBaseClass {
    public var entity(default, null):Entity = new Entity();
    @:once public var obj:Obj;
    @:once("named") public var named:Obj;

    public function new() {
        watch(entity);
        // entity.onContext.listen(_init);
        // entity.dispatchContext();
    }

    function _init(e) {}

    public function init() {}
}

class Obj {
    static var count = 0;

    public var id(default, null):Int;

    var name = "noname";

    public function new(n = null) {
        if (n != null)
            name = n;
        id = count++;
    }

    function toString() {
        return name + "_" + id;
    }
}
