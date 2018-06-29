function tests = testslm
  tests = functiontests(localfunctions);
end

function testSimple(tests)

  slm = otslm.utils.TestSlm();
  pattern = otslm.simple.linear(slm.size, 10);
  slm.show(pattern);

  cam = otslm.utils.TestCamera(slm);
  im = cam.viewTarget();

end
