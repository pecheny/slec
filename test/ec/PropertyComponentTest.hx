package ec;
import ec.PropertyComponent;
import utest.Assert;
import utest.Test;

class PropertyComponentTest extends Test{
    public function test_getOrCreate() {
        var e = new ec.Entity();
        var tp = TestFlag.getOrCreate(e);
        Assert.isOfType(tp, TestFlag);
    }

    public function test_IntPropertComponent() {
        var e = new ec.Entity();
        var tp = IntPropComponent.getOrCreate(e);
        var res = 0;
        tp.onChange.listen(() -> res = tp.value);
        tp.value = 5;
        Assert.equals(5, tp.value);
    
    }
}

class TestFlag extends FlagComponent {
    
}

class IntPropComponent extends PropertyComponent<Int> {
    
}