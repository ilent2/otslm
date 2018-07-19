function tests = testImageDevice()
  tests = functiontests(localfunctions);
end

function setupOnce(tests)

  % Add toolbox to path
  addpath('../../');

  % Create objects for testing
  tests.TestData.slm = otslm.utils.TestSlm();
  tests.TestData.cam = otslm.utils.TestCamera(tests.TestData.slm);

end

function testScan1d(tests)

  slm = tests.TestData.slm;
  cam = tests.TestData.cam;
  im = otslm.utils.image_device(slm, cam, 'method', 'scan1d');

end

function testScan2d(tests)

  slm = tests.TestData.slm;
  cam = tests.TestData.cam;
  im = otslm.utils.image_device(slm, cam, 'method', 'scan2d');
  
end