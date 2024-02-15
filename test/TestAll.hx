import ec.PropertyComponentTest;
import ec.InitMacroTest;
import ec.ContextBindingTest;
import ec.EntityTest;
import utest.Runner;
import utest.ui.Report;

class TestAll {
    public static function main() {
        var runner = new Runner();
        runner.addCase(new EntityTest());
        runner.addCase(new ContextBindingTest());
        runner.addCase(new InitMacroTest());
        runner.addCase(new PropertyComponentTest());
        Report.create(runner);
        runner.run();
    }
}