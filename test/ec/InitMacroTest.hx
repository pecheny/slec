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

    public function test_optional_injection() {
        var root = new Entity();
        var c1 = new Obj();
        var c2 = new Obj("named");
        root.addComponentByName("Obj_named", c2);
        var tester = new OptInjTester();
        root.addChild(tester.entity);

        Assert.equals(1, tester.entity.onContext.asArray().length);
        Assert.equals(1, tester.initCalls);
        Assert.equals(null, tester.opt);

        root.addComponent(c1);
        Assert.equals(1, tester.initCalls);
        Assert.equals(c1, tester.opt);
        Assert.equals(0, tester.entity.onContext.asArray().length);
    }
    
    public function test_setter() {
        var root = new Entity();
        var c1 = new Obj();
        var tester = new OptInjTester();
        root.addChild(tester.entity);
        root.addComponent(c1);
        Assert.equals(1, tester.setCalls);
        Assert.equals(c1, tester.setter);
    }
}

class OptInjTester extends MacroBaseClass {
    public var entity(default, null):Entity = new Entity();
    @:onceOpt public var opt:Obj;
    @:onceOpt public var setter (default, set):Obj;
    @:once("named") public var named:Obj;
    public var initCalls = 0;
    public var setCalls = 0;

    public function init() {
        initCalls++;
    }

    public function new() {
        watch(entity);
    }
    
    

    function set_setter(value:Obj):Obj {
        if (value != null) setCalls++;
        return setter = value;
    }
}

class ExtendedINjectionTester extends InjectionTester {
    @:once("otherNamed") public var other:Obj;
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
