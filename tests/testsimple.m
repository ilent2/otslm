function tests = testsimple
  % SIMPLE tests for otslm.simple.*
  %
  % These tests are primarily to test everything runs, we should
  % write better tests in future.

  tests = functiontests(localfunctions);
end

function setupOnce(testCase)
  addpath('../');
end

function testAperture(testCase)
  sz = [512, 512];

  pattern = otslm.simple.aperture(sz, 100, 'type', 'circle');
  pattern = otslm.simple.aperture(sz, 100, 'type', 'square');
  pattern = otslm.simple.aperture(sz, [100, 200], 'type', 'rect');
  pattern = otslm.simple.aperture(sz, [100, 200], 'type', 'ring');
  assert(islogical(pattern));

  pattern = otslm.simple.aperture(sz, 100, 'value', [0, 1]);
  assert(isnumeric(pattern));
end

function testAspheric(testCase)
  sz = [512, 512];
  pattern = otslm.simple.aspheric(sz, 10, 0.33);
end

function testAxicon(testCase)
  sz = [512, 512];
  pattern = otslm.simple.axicon(sz, 1/100);
end

function testBessel(testCase)
  sz = [512, 512];
  pattern = otslm.simple.bessel(sz, 0);
end

function testCheckerboard(testCase)
  sz = [512, 512];
  pattern = otslm.simple.checkerboard(sz);
end

function testGaussian(testCase)
  sz = [512, 512];
  pattern = otslm.simple.gaussian(sz, 100);
end

function testHgmode(testCase)
  sz = [512, 512];
  pattern = otslm.simple.hgmode(sz, 3, 2);
end

function testIgmode(testCase)
  sz = [512, 512];

  % Test even modes
  pattern = otslm.simple.igmode(sz, true, 4, 2, 1.0);

  % Test odd modes
  pattern = otslm.simple.igmode(sz, false, 4, 2, 1.0);
end

function testLgmode(testCase)
  sz = [512, 512];
  pattern = otslm.simple.lgmode(sz, -3, 2);
end

function testLinear(testCase)
  % Test single spacing
  pattern = otslm.simple.linear([512, 512], 10);

  % Test multiple spacings for different directions
  pattern = otslm.simple.linear([512, 512], [10, 20]);

  % Test negative spacing
  pattern1 = otslm.simple.linear([512, 512], 10);
  pattern2 = otslm.simple.linear([512, 512], -10);
  assert(all(pattern1(:) + pattern2(:) == pattern1(1) + pattern2(1)));

  % Test negative spacing with angle
  pattern1 = otslm.simple.linear([512, 512], 10, 'angle_deg', 0);
  pattern2 = otslm.simple.linear([512, 512], -10, 'angle_deg', 0);
  assert(all(pattern1(:) + pattern2(:) == pattern1(1) + pattern2(1)));
end

function testGrid(testCase)
  sz = [512, 512];
  pattern = otslm.simple.grid(sz, 'angle', 0.1);
end

function testCubic(testCase)
  sz = [512, 512];
  pattern = otslm.simple.cubic(sz);
end

function testParabolic(testCase)
  sz = [512, 512];
  pattern = otslm.simple.parabolic(sz, [1, 2]);
end

function testRandom(testCase)
  sz = [512, 512];
  pattern = otslm.simple.random(sz);
  pattern = otslm.simple.random(sz, 'type', 'gaussian');
  pattern = otslm.simple.random(sz, 'type', 'binary');
end

function testSinusoid(testCase)
  sz = [512, 512];
  pattern = otslm.simple.sinusoid(sz, 100);
  pattern = otslm.simple.sinusoid(sz, 100, 'type', '1d');
  pattern = otslm.simple.sinusoid(sz, 100, 'type', '2dcart');
  pattern = otslm.simple.sinusoid(sz, [100, 50], 'type', '2dcart');
end

function testSinc(testCase)
  sz = [512, 512];
  pattern = otslm.simple.sinc(sz, 100);
  pattern = otslm.simple.sinc(sz, 100, 'type', '1d');
  pattern = otslm.simple.sinc(sz, 100, 'type', '2dcart');
  pattern = otslm.simple.sinc(sz, [100, 50], 'type', '2dcart');
end

function testSpherical(testCase)
  sz = [512, 512];
  pattern = otslm.simple.spherical(sz, 100);
  pattern = otslm.simple.spherical(sz, 100, 'background', 'random');
  pattern = otslm.simple.spherical(sz, 100, 'background', 'checkerboard');
end

function testStep(testCase)

  sz = [512, 512];

  p1 = otslm.simple.step(sz);

  p2 = otslm.simple.step(sz, 'centre', [0, 0], 'angle', pi/2.0, 'value', [0.5, 1]);

  p3 = otslm.simple.step(sz, 'angle_deg', 45.0);

end

function testZernike(testCase)
  sz = [512, 512];
  pattern = otslm.simple.zernike(sz, 4, 5);
end

function testAperture3d(testCase)

  sz = [100, 100, 100];
  radius = 50;
  
  pattern = otslm.simple.aperture3d(sz, radius, ...
    'type', 'sphere', 'value', [0, 10]);

end



