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
}

@:build(ec.macros.InitMacro.build())
class InjectionTester {
    public var entity(default, null):Entity = new Entity();
    @:once public var obj:Obj;
    @:once("named") public var named:Obj;


    public function new() {
        entity.onContext.listen(_init);
        _init(entity.parent);
    }

    function _init(e){
    }

    public function init() {
    }
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

    function toString(){
        return name  + "_" + id;
    }
}
