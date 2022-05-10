package test;

import utest.ui.Report;
import utest.Runner;

class RunTests {
    public static function main() {
        var runner = new Runner();
        runner.addCase(new GridTests());
        Report.create(runner);
        runner.run();
      }
}
