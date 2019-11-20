function tests = testcombine()
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)

  addpath('../../');
  
  sz = [512, 512];
  p1 = otslm.simple.linear(sz, 10);
  p2 = otslm.simple.linear(sz, -10);
  
  testCase.TestData.patterns = {p1, p2};

end

function helperTestDefault(testCase, method_name)

  import matlab.unittest.constraints.IsEqualTo;
  import matlab.unittest.constraints.AbsoluteTolerance;

  % Test size of output
  out = otslm.tools.combine(testCase.TestData.patterns, ...
    'method', method_name);
  testCase.verifyThat(size(out), ...
    IsEqualTo(size(testCase.TestData.patterns{1})), ...
    'Output size is incorrect');
  
  % Test single input
  pat = linspace(-0.5, 0.5, 20);
  out = otslm.tools.combine({pat}, 'method', method_name);
  testCase.verifyThat(out, ...
    IsEqualTo(pat, 'within', AbsoluteTolerance(1e-6)), ...
    'Single pattern output not equal');
end

function testDefault(testCase)
  
  otslm.tools.combine(testCase.TestData.patterns);

end

function testDither(testCase)
  helperTestDefault(testCase, 'dither');
end

function testSuper(testCase)
  helperTestDefault(testCase, 'super');
end

function testRsuper(testCase)
  otslm.tools.combine(testCase.TestData.patterns, 'method', 'rsuper');
end

function testFarfield(testCase)
  otslm.tools.combine(testCase.TestData.patterns, 'method', 'farfield');
end

function testAdd(testCase)
  helperTestDefault(testCase, 'add');
end

function testMultiply(testCase)
  helperTestDefault(testCase, 'multiply');
end

function testAddAngle(testCase)
  helperTestDefault(testCase, 'addangle');
end

function testAverage(testCase)
  helperTestDefault(testCase, 'average');
end

function testWeights(testCase)

  import matlab.unittest.constraints.IsEqualTo;
  import matlab.unittest.constraints.AbsoluteTolerance;

  pat1 = linspace(-0.5, 0.5, 100);
  pat2 = linspace(0.5, -0.5, 100);

  out = otslm.tools.combine({pat1, pat2}, 'method', 'super', ...
    'weights', [1, 0]);
  testCase.verifyThat(out, ...
    IsEqualTo(pat1, 'within', AbsoluteTolerance(1e-6)), ...
    'Incorrect output');
  
end
