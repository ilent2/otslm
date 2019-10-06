function tests = testObjectives
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)
  addpath('../../');
end

function testFlatness(testCase)

  import matlab.unittest.constraints.IsEqualTo;
  import matlab.unittest.constraints.IsGreaterThan;
  import matlab.unittest.constraints.AbsoluteTolerance;
  abstol = 1.0e-4;

  sz = [512, 512];

  target = ones(sz);
  obj = otslm.iter.objectives.Flatness('target', target);
  
  f0 = obj.evaluate(zeros(sz));
  testCase.verifyThat(f0, IsEqualTo(0, ...
      'Within', AbsoluteTolerance(abstol)), ...
      'Zeros trial failed');
  
  f1 = obj.evaluate(randn(sz) + 1.0);
  testCase.verifyThat(f1, IsGreaterThan(1), ...
      'Randn trial failed');
  
  f2 = obj.evaluate(ones(sz));
  testCase.verifyThat(f2, IsEqualTo(0, ...
      'Within', AbsoluteTolerance(abstol)), ...
      'ones trial failed');
  
  f3 = obj.evaluate(0.8*ones(sz));
  testCase.verifyThat(f3, IsEqualTo(0, ...
      'Within', AbsoluteTolerance(abstol)), ...
      '0.8*ones trial failed');
    
end

function testIntensity(testCase)

  import matlab.unittest.constraints.IsEqualTo;
  import matlab.unittest.constraints.IsLessThan;
  import matlab.unittest.constraints.AbsoluteTolerance;
  abstol = 1.0e-4;

  sz = [512, 512];

  target = ones(sz);
  obj = otslm.iter.objectives.Intensity('target', target);
  
  f0 = obj.evaluate(zeros(sz));
  testCase.verifyThat(f0, IsEqualTo(0, ...
      'Within', AbsoluteTolerance(abstol)));
  
  f1 = obj.evaluate(0.1*randn(sz) + 1.0);
  disp(f1);
  testCase.verifyThat(f1, IsLessThan(0));
  
  f2 = obj.evaluate(ones(sz));
  testCase.verifyThat(f2, IsEqualTo(-1, ...
      'Within', AbsoluteTolerance(abstol)));
  
  s = 0.8;
  f3 = obj.evaluate(s*ones(sz));
  testCase.verifyThat(f3, IsEqualTo(-s^2, ...
      'Within', AbsoluteTolerance(abstol)));
  
  s = 1.2;
  f4 = obj.evaluate(s*ones(sz));
  testCase.verifyThat(f4, IsEqualTo(-s^2, ...
      'Within', AbsoluteTolerance(abstol)));
    
end

function testFlatIntensity(testCase)

  import matlab.unittest.constraints.IsEqualTo;
  import matlab.unittest.constraints.AbsoluteTolerance;
  abstol = 1.0e-4;

  sz = [512, 512];

  target = ones(sz);
  obj = otslm.iter.objectives.FlatIntensity('target', target);
  
  f0 = obj.evaluate(zeros(sz));
  testCase.verifyThat(f0, IsEqualTo(0, ...
      'Within', AbsoluteTolerance(abstol)), ...
      'zeros trial failed');
  
  s = 0.8;
  f1 = obj.evaluate(s*ones(sz));
  testCase.verifyThat(f1, IsEqualTo(-s^2, ...
      'Within', AbsoluteTolerance(abstol)));
    
end

function testRmsIntensity(testCase)

  import matlab.unittest.constraints.IsEqualTo;
  import matlab.unittest.constraints.AbsoluteTolerance;
  abstol = 1.0e-4;

  sz = [512, 512];

  target = ones(sz);
  obj = otslm.iter.objectives.RmsIntensity('target', target);
  
  f0 = obj.evaluate(zeros(sz));
  testCase.verifyThat(f0, IsEqualTo(1, ...
      'Within', AbsoluteTolerance(abstol)), ...
      'zeros trial failed');
  
  s = 0.8;
  f1 = obj.evaluate(s*ones(sz));
  testCase.verifyThat(f1, IsEqualTo(1 - s^2, ...
      'Within', AbsoluteTolerance(abstol)), ...
      '0.8*ones trial failed');
    
end

function testBowman2017(testCase)

  import matlab.unittest.constraints.IsEqualTo;
  import matlab.unittest.constraints.AbsoluteTolerance;
  abstol = 1.0e-4;

  sz = [512, 512];

  target = ones(sz);
  obj = otslm.iter.objectives.Bowman2017('target', target);
  
  f0 = obj.evaluate(zeros(sz));
  testCase.verifyThat(f0, IsEqualTo(10^0.5, ...
      'Within', AbsoluteTolerance(abstol)), ...
      'zeros trial failed');
  
  f1 = obj.evaluate(ones(sz));
  testCase.verifyThat(f1, IsEqualTo(0.0, ...
      'Within', AbsoluteTolerance(abstol)), ...
      'ones trial failed');
    
end

function testGoorden2014(testCase)

  import matlab.unittest.constraints.IsEqualTo;
  import matlab.unittest.constraints.AbsoluteTolerance;
  abstol = 1.0e-4;

  sz = [512, 512];

  target = ones(sz);
  obj = otslm.iter.objectives.Goorden2014('target', target);
  
  f0 = obj.evaluate(zeros(sz));
  testCase.verifyThat(f0, IsEqualTo(1.0, ...
      'Within', AbsoluteTolerance(abstol)), ...
      'zeros trial failed');
  
  f1 = obj.evaluate(ones(sz));
  testCase.verifyThat(f1, IsEqualTo(0.0, ...
      'Within', AbsoluteTolerance(abstol)), ...
      'ones trial failed');
    
end
