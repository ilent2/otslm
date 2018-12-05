function tests = testcalibrate
  tests = functiontests(localfunctions);
end

function setupOnce(tests)

  % Add toolbox to path
  addpath('../../');

  % Create objects for testing
  values = 1:10;
  tests.TestData.lut = otslm.utils.LookupTable(...
    linspace(0, 2*pi, length(values)).', values.', 'range', 2*pi);
  tests.TestData.slm = otslm.utils.TestSlm(...
    'lookup_table', tests.TestData.lut, 'value_range', {values});
  tests.TestData.cam = otslm.utils.TestFarfield(tests.TestData.slm);
  tests.TestData.inf = otslm.utils.TestMichelson(tests.TestData.slm);

end

function testChecker(tests)
  % Method subtimes produces sign error problems

  lut = otslm.utils.calibration.checker(tests.TestData.slm, tests.TestData.cam, ...
    'verbose', false);
  
  import matlab.unittest.constraints.IsEqualTo;
  import matlab.unittest.constraints.AbsoluteTolerance;
  abstol = 4.0e-1;
  tests.verifyThat(2*pi-lut.phase, IsEqualTo(tests.TestData.lut.phase, ...
    'Within', AbsoluteTolerance(abstol)));
end

function testMichelson(tests)

  % Set tilt angle
  tests.TestData.inf.tilt = 0;
  
  lut = otslm.utils.calibration.michelson(tests.TestData.slm, tests.TestData.inf, ...
    'verbose', false);
  
  import matlab.unittest.constraints.IsEqualTo;
  import matlab.unittest.constraints.AbsoluteTolerance;
  abstol = 4.0e-1;
  tests.verifyThat(lut.phase, IsEqualTo(tests.TestData.lut.phase, ...
    'Within', AbsoluteTolerance(abstol)));
end

function testSmichelson(tests)

  % Set tilt angle
  tests.TestData.inf.tilt = 20;

  lut = otslm.utils.calibration.smichelson(tests.TestData.slm, tests.TestData.inf, ...
      'stride', 1, 'verbose', false, ...
      'slice1_offset', -10, 'slice2_offset', 10, ...
      'slice1_width', 5, 'slice2_width', 5, ...
      'slice_angle', 0, 'freq_index', 29, 'step_angle', 90);
  
  import matlab.unittest.constraints.IsEqualTo;
  import matlab.unittest.constraints.AbsoluteTolerance;
  abstol = 1.0e-1;
  tests.verifyThat(lut.phase, IsEqualTo(tests.TestData.lut.phase, ...
    'Within', AbsoluteTolerance(abstol)));
end

function testStep(tests)
  lut = otslm.utils.calibration.step(tests.TestData.slm, tests.TestData.cam, ...
    'stride', 1, 'verbose', false, 'step_angle', 0, ...
    'show_spectrum', false, 'freq_index', 200);
  
  import matlab.unittest.constraints.IsEqualTo;
  import matlab.unittest.constraints.AbsoluteTolerance;
  abstol = 1.0e-1;
  tests.verifyThat(lut.phase, IsEqualTo(tests.TestData.lut.phase, ...
    'Within', AbsoluteTolerance(abstol)));
end

function testPinholes(tests)
  lut = otslm.utils.calibration.pinholes(tests.TestData.slm, tests.TestData.cam, ...
    'stride', 1, 'verbose', false, ...
    'slice_angle', 0, 'slice_width', 10, ...
    'show_spectrum', false, 'freq_index', 200, ...
    'radius', 10);
  
  import matlab.unittest.constraints.IsEqualTo;
  import matlab.unittest.constraints.AbsoluteTolerance;
  abstol = 1.0e-1;
  tests.verifyThat(lut.phase, IsEqualTo(tests.TestData.lut.phase, ...
    'Within', AbsoluteTolerance(abstol)));
end

function testLinear(tests)
  lut = otslm.utils.calibration.linear(tests.TestData.slm, tests.TestData.cam, ...
    'max_iterations', 10, 'show_progress', false);
end

