import ec.ContextBindingTest;
import ec.EntityTest;
import utest.Runner;
import utest.ui.Report;

class TestAll {
    public static function main() {
        //the long way
        var runner = new Runner();
        runner.addCase(new EntityTest());
        runner.addCase(new ContextBindingTest());
        Report.create(runner);
        runner.run();

        //the short way in case you don't need to handle any specifics
//        utest.UTest.run([]);
    }
}