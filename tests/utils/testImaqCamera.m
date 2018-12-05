function tests = testImaqCamera
  tests = functiontests(localfunctions);
end

function setupOnce(tests)
  addpath('../../');
end

function testCamera(tests)

  cam = otslm.utils.ImaqCamera('winvideo', 1);
  im = cam.viewTarget();

end