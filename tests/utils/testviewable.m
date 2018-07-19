function tests = testviewable()
  tests = functiontests(localfunctions);
end

function testcrop(tests)

  addpath('../../');
  
  slm = otslm.utils.TestSlm();
  cam = otslm.utils.TestCamera(slm);

  cam.crop([100, 100, 100, 100]);
  
  cam.crop([]);

end