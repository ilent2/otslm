function tests = simple
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)
end

function testAspheric(testCase)
  % TODO
end

function testAxicon(testCase)
  % TODO
end

function testCheckerboard(testCase)
  % TODO
end

function testGaussian(testCase)
  % TODO
end

function testHgmode(testCase)
  % TODO
end

function testLgmode(testCase)
  % TODO
end

function testLinear(testCase)
  % TODO
end

function testParabolic(testCase)
  % TODO
end

function testRandombin(testCase)
  % TODO
end

function testRandom(testCase)
  % TODO
end

function testSinusoid(testCase)
  % TODO
end

function testSpherical(testCase)
  % TODO
end

function testStep(testCase)

  import otslm.simple.step;
  sz = [512, 512];

  p1 = step(sz);

  p2 = step(sz, 'centre', [0, 0], 'angle', pi/2.0, 'value', [0.5, 1]);

  p3 = step(sz, 'angle_deg', 45.0);

end

function testZernike(testCase)
  % TODO
end

