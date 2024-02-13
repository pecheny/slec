package ec;
import ec.FlagComponent;
import utest.Assert;
import utest.Test;

class FlagComponentTest extends Test{
    public function test_getOrCreate() {
        var e = new ec.Entity();
        var tp = TestFlag.getOrCreate(e);
        Assert.isOfType(tp, TestFlag);
    }
}

class TestFlag extends FlagComponent {
    
}
