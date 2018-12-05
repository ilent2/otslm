function tests = testslm
  tests = functiontests(localfunctions);
end

function setupOnce(tests)

  addpath('../../');

  % Create objects for testing
  tests.TestData.slm = otslm.utils.TestSlm();
  tests.TestData.cam = otslm.utils.TestFarfield(tests.TestData.slm);
end

function testSimple(tests)

  slm = tests.TestData.slm;
  pattern = otslm.simple.linear(slm.size, 10);
  slm.show(pattern);

  cam = tests.TestData.cam;
  im = cam.viewTarget();

end

function testShowComplex(tests)

  slm = tests.TestData.slm;
  im = slm.viewComplex(zeros(slm.size));

end