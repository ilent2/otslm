function tests = testImageDevice()
  tests = functiontests(localfunctions);
end

function setupOnce(tests)

  % Add toolbox to path
  addpath('../../');

  % Create objects for testing
  tests.TestData.slm = otslm.utils.TestSlm('size', [20, 20]);
  tests.TestData.cam = otslm.utils.TestFarfield(tests.TestData.slm);

end

function testScan1d(tests)

  slm = tests.TestData.slm;
  cam = tests.TestData.cam;
  im = otslm.utils.imaging.scan1d(slm, cam, 'verbose', false);

end

function testScan2d(tests)

  slm = tests.TestData.slm;
  cam = tests.TestData.cam;
  im = otslm.utils.imaging.scan2d(slm, cam, 'verbose', false);
  
end