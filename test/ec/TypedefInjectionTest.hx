package ec;

import utest.Assert;
import ec.Entity;
import ec.InitMacroTest.MacroBaseClass;

class TypedefInjectionTest extends utest.Test {
    var n = () -> "named";

    public function test_init_once() {
        var root = new Entity();
        var c1:Foo = {bar: "baz"};
        var c2:Foo = {bar: "named"};
        root.addTypedef(c1);
        root.addTypedef(c2, n());

        var tester = new TDDep();
        root.addChild(tester.entity);
        Assert.equals(c1, tester.dep, "Test @:once injection");
        Assert.equals(c2, tester.named, "Test named injection");
    }
}

typedef Foo = {bar:String}

class TDDep extends MacroBaseClass {
    public var entity(default, null):Entity = new Entity();
    @:once("named") public var named:Foo;
    @:once public var dep:Foo;

    public function new() {
        watch(entity);
    }
}
