function tests = calibrate
  tests = functiontests(localfunctions);
end

function setupOnce(tests)

  % Add toolbox to path
  addpath('../../');

  % Create objects for testing
  tests.TestData.slm = otslm.utils.TestSlm();
  tests.TestData.cam = otslm.utils.TestCamera(slm);
  tests.TestData.inf = otslm.utils.TestMichelson(slm);

end

function testChecker(tests)
  lut = otslm.utils.calibrate(tests.TestData.slm, tests.TestData.cam, ...
      'method', 'checker');
end

function testMichelson(tests)
  lut = otslm.utils.calibrate(tests.TestData.slm, tests.TestData.inf, ...
      'method', 'michelson');
end

function testSmichelson(tests)
  lut = otslm.utils.calibrate(tests.TestData.slm, tests.TestData.inf, ...
      'method', 'smichelson');
end

function testStep(tests)
  lut = otslm.utils.calibrate(tests.TestData.slm, tests.TestData.cam, ...
      'method', 'step');
end

function testPinholes(tests)
  lut = otslm.utils.calibrate(tests.TestData.slm, tests.TestData.cam, ...
      'method', 'pinholes');
end

function testLinear(tests)
  lut = otslm.utils.calibrate(tests.TestData.slm, tests.TestData.cam, ...
      'method', 'linear');
end

