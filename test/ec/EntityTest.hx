package ec;
import utest.Assert;
import utest.Test;
import ec.Entity;
class EntityTest extends Test {

    // boring
    // add / get / has by name/type/...
    // onCtx

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