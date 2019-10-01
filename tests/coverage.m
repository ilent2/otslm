% Run a test with the coverage report

import matlab.unittest.TestSuite
import matlab.unittest.TestRunner
import matlab.unittest.plugins.CodeCoveragePlugin

%% Run everything

suite = TestSuite.fromFolder('tests', 'IncludingSubfolders', true);
runner = TestRunner.withTextOutput;
runner.addPlugin(CodeCoveragePlugin.forPackage(...
  {'otslm.simple', 'otslm.iter', 'otslm.utils', 'otslm.tools'}, 'IncludingSubpackages', true))
result = runner.run(suite);

%% otslm.simple

suite = TestSuite.fromFile('tests\testsimple.m');
runner = TestRunner.withTextOutput;
runner.addPlugin(CodeCoveragePlugin.forPackage('otslm.simple', 'IncludingSubpackages', true))
result = runner.run(suite);

%% otslm.iter

suite = TestSuite.fromFolder('tests\iter');
runner = TestRunner.withTextOutput;
runner.addPlugin(CodeCoveragePlugin.forPackage('otslm.iter', 'IncludingSubpackages', true))
result = runner.run(suite);

%% otslm.tools

suite = TestSuite.fromFolder('tests\tools');
runner = TestRunner.withTextOutput;
runner.addPlugin(CodeCoveragePlugin.forPackage('otslm.tools', 'IncludingSubpackages', true))
result = runner.run(suite);

%% otslm.utils

suite = TestSuite.fromFolder('tests\utils');
runner = TestRunner.withTextOutput;
runner.addPlugin(CodeCoveragePlugin.forPackage('otslm.utils', 'IncludingSubpackages', true))
result = runner.run(suite);