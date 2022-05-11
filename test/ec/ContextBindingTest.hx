package ec;
import utest.Assert;
import ec.CtxWatcher.CtxBinder;
import utest.Test;
class ContextBindingTest extends Test {

    function test_should_bind_after_adding_to_hierarchy() {
        var root = new Entity();
        var rootCollector:ChildCollector = root.addComponent(new ChildCollector());
        var child = new Entity();
        new CtxWatcher(ChildCollector, child);
        root.addChild(child);
        Assert.contains(child, rootCollector.children);
    }

    function test_should_bind_after_watcher_creation() {
        var root = new Entity();
        var rootCollector:ChildCollector = root.addComponent(new ChildCollector());
        var child = new Entity();
        root.addChild(child);
        new CtxWatcher(ChildCollector, child);
        Assert.contains(child, rootCollector.children);
    }

    function test_should_bind_after_adding_component() {
        var root = new Entity();
        new CtxWatcher(ChildCollector, root);
        var rootCollector:ChildCollector = root.addComponent(new ChildCollector());
        Assert.contains(root, rootCollector.children);
    }

    function test_should_bind_after_adding_to_hierarchy_upward() {
        var root = new Entity();
        var rootCollector:ChildCollector = root.addComponent(new ChildCollector());
        var child = new Entity();
        var childCollector:ChildCollector = child.addComponent(new ChildCollector());
        new CtxWatcher(ChildCollector, child, true);
        root.addChild(child);
        Assert.contains(child, rootCollector.children);
        Assert.notContains(child, childCollector.children);
    }

    function test_should_bind_after_watcher_creation_upward() {
        var root = new Entity();
        var rootCollector:ChildCollector = root.addComponent(new ChildCollector());
        var child = new Entity();
        var childCollector:ChildCollector = child.addComponent(new ChildCollector());
        root.addChild(child);
        new CtxWatcher(ChildCollector, child, true);
        Assert.contains(child, rootCollector.children);
        Assert.notContains(child, childCollector.children);
    }

    function test_should_bind_after_adding_component_upward() {
        var root = new Entity();
        var child = new Entity();
        var childCollector:ChildCollector = child.addComponent(new ChildCollector());
        root.addChild(child);
        new CtxWatcher(ChildCollector, child, true);
        Assert.notContains(child, childCollector.children);
        var rootCollector:ChildCollector = root.addComponent(new ChildCollector());
        Assert.notContains(child, childCollector.children);
        Assert.contains(child, rootCollector.children);
    }

    // chech existent watcher collisions

    function test_should_rebind_after_secondary_watcher_creation():Void {
        var child = new Entity();
        var collector = child.addComponent(new BinderWithComponentChecking());
        new CtxWatcher(ChildCollector, child);
        Assert.notContains(child, collector.children);
        child.addComponent(new TestComponent2());
        new CtxWatcher(BinderWithComponentChecking, child);
        Assert.contains(child, collector.children);
    }

    function test_should_rebind_after_secondary_watcher_creation_upward():Void {
        var root = new Entity();
        var child = new Entity();
        var collector = root.addComponent(new BinderWithComponentChecking());
        root.addChild(child);
        new CtxWatcher(BinderWithComponentChecking, child, true);
        Assert.notContains(child, collector.children);
        child.addComponent(new TestComponent2());
        new CtxWatcher(BinderWithComponentChecking, child, true);
        Assert.contains(child, collector.children);
    }
}

class ChildCollector implements CtxBinder {
    public var children:Array<Entity> = [];

    public function new() {}

    public function bind(e:Entity):Void {
        children.push(e);
    }

    public function unbind(e:Entity):Void {
        children.remove(e);
    }
}

class BinderWithComponentChecking implements CtxBinder {
    public var children:Array<Entity> = [];

    public function new() {}

    public function bind(e:Entity):Void {
        if (e.hasComponent(TestComponent2))
            children.push(e);
    }

    public function unbind(e:Entity):Void {
        children.remove(e);
    }
}

class TestComponent2 {
    public function new() {}
}
