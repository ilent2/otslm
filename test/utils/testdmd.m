function tests = testdmd
  tests = functiontests(localfunctions);
end

function testSimple(tests)

  slm = otslm.utils.TestDmd();
  pattern = otslm.simple.sinusoid(slm.size, 10, ...
      'type', '1d', 'aspect', 2.0);
  slm.show(pattern);

  cam = otslm.utils.TestCamera(slm);
  im = cam.viewTarget();

end
