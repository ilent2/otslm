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
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  pattern = otslm.simple.aperture(sz, 100, 'type', 'square', 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
  
  pattern = otslm.simple.aperture(sz, [100, 200], 'type', 'rect');
  pattern = otslm.simple.aperture(sz, [100, 200], 'type', 'ring');
  assert(islogical(pattern));

  pattern = otslm.simple.aperture(sz, 100, 'value', [0, 1]);
  assert(isnumeric(pattern));
end

function testAspheric(testCase)
  sz = [512, 512];
  pattern = otslm.simple.aspheric(sz, 10, 0.33);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  pattern = otslm.simple.aspheric(sz, 10, 0.33, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testAxicon(testCase)
  sz = [512, 512];
  pattern = otslm.simple.axicon(sz, 1/100);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  pattern = otslm.simple.axicon(sz, 1/100, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testBessel(testCase)
  sz = [512, 512];
  pattern = otslm.simple.bessel(sz, 0);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  pattern = otslm.simple.bessel(sz, 0, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testCheckerboard(testCase)
  sz = [512, 512];
  
  pattern = otslm.simple.checkerboard(sz, 'value', [false, true]);
  testCase.verifyClass(pattern, 'logical', 'wrong type (logical)');
  
  pattern = otslm.simple.checkerboard(sz);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  pattern = otslm.simple.checkerboard(sz, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testGaussian(testCase)
  sz = [512, 512];
  pattern = otslm.simple.gaussian(sz, 100);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  pattern = otslm.simple.gaussian(sz, 100, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testHgmode(testCase)
  sz = [512, 512];
  pattern = otslm.simple.hgmode(sz, 3, 2);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  pattern = otslm.simple.hgmode(sz, 3, 2, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testIgmode(testCase)
  sz = [512, 512];

  % Test even modes
  pattern = otslm.simple.igmode(sz, true, 4, 2, 1.0);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');

  % Test odd modes
  pattern = otslm.simple.igmode(sz, false, 4, 2, 1.0, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testLgmode(testCase)
  sz = [512, 512];
  pattern = otslm.simple.lgmode(sz, -3, 2);
  testCase.verifyClass(pattern, 'double', 'wrong type');
  
  pattern = otslm.simple.lgmode(sz, -3, 2, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
  
  [~, amplitude] = otslm.simple.lgmode(sz, -3, 2);
  testCase.verifyClass(amplitude, 'double', 'wrong type for amplitude');
  
  [~, amplitude] = otslm.simple.lgmode(sz, -3, 2, 'gpuArray', true);
  testCase.verifyClass(amplitude, 'gpuArray', 'wrong type for amplitude');
end

function testLinear(testCase)
  % Test single spacing
  pattern = otslm.simple.linear([512, 512], 10);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');

  % Test multiple spacings for different directions
  pattern = otslm.simple.linear([512, 512], [10, 20], 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');

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
  sz = [20, 20];
  [xx, yy, rr, phi] = otslm.simple.grid(sz, 'angle', 0.1);
  testCase.verifyClass(xx, 'double', 'xx invalid');
  testCase.verifyClass(yy, 'double', 'yy invalid');
  testCase.verifyClass(rr, 'double', 'rr invalid');
  testCase.verifyClass(phi, 'double', 'phi invalid');
  
  [xx, yy, rr, phi] = otslm.simple.grid(sz, 'angle', 0.1, 'gpuArray', true);
  testCase.verifyClass(xx, 'gpuArray', 'xx invalid');
  testCase.verifyClass(yy, 'gpuArray', 'yy invalid');
  testCase.verifyClass(rr, 'gpuArray', 'rr invalid');
  testCase.verifyClass(phi, 'gpuArray', 'phi invalid');
end

function testCubic(testCase)
  sz = [512, 512];
  pattern = otslm.simple.cubic(sz);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  pattern = otslm.simple.cubic(sz, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testParabolic(testCase)
  sz = [512, 512];
  pattern = otslm.simple.parabolic(sz, [1, 2]);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  pattern = otslm.simple.parabolic(sz, [1, 2], 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testRandom(testCase)
  sz = [512, 512];
  pattern = otslm.simple.random(sz);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  pattern = otslm.simple.random(sz, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
  
  pattern = otslm.simple.random(sz, 'type', 'gaussian');
  pattern = otslm.simple.random(sz, 'type', 'binary');
end

function testSinusoid(testCase)
  sz = [512, 512];
  pattern = otslm.simple.sinusoid(sz, 100);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  pattern = otslm.simple.sinusoid(sz, 100, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
  
  pattern = otslm.simple.sinusoid(sz, 100, 'type', '1d');
  pattern = otslm.simple.sinusoid(sz, 100, 'type', '2dcart');
  pattern = otslm.simple.sinusoid(sz, [100, 50], 'type', '2dcart');
end

function testSinc(testCase)
  sz = [512, 512];
  pattern = otslm.simple.sinc(sz, 100);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  pattern = otslm.simple.sinc(sz, 100, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
  
  pattern = otslm.simple.sinc(sz, 100, 'type', '1d');
  pattern = otslm.simple.sinc(sz, 100, 'type', '2dcart');
  pattern = otslm.simple.sinc(sz, [100, 50], 'type', '2dcart');
end

function testSpherical(testCase)
  sz = [512, 512];
  pattern = otslm.simple.spherical(sz, 100);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  pattern = otslm.simple.spherical(sz, 100, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
  
  pattern = otslm.simple.spherical(sz, 100, 'background', 'random');
  pattern = otslm.simple.spherical(sz, 100, 'background', 'checkerboard');
end

function testStep(testCase)

  sz = [512, 512];

  p1 = otslm.simple.step(sz);
  testCase.verifyClass(p1, 'double', 'wrong type (double)');

  p2 = otslm.simple.step(sz, 'centre', [0, 0], 'angle', pi/2.0, 'value', [0.5, 1]);

  p3 = otslm.simple.step(sz, 'angle_deg', 45.0, 'gpuArray', true);
  testCase.verifyClass(p3, 'gpuArray', 'wrong type (gpu)');

end

function testZernike(testCase)
  sz = [512, 512];
  pattern = otslm.simple.zernike(sz, 4, 5);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  pattern = otslm.simple.zernike(sz, 4, 5, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testAperture3d(testCase)

  sz = [100, 100, 100];
  radius = 50;
  
  pattern = otslm.simple.aperture3d(sz, radius, ...
    'type', 'sphere', 'value', [0, 10]);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  pattern = otslm.simple.aperture3d(sz, radius, ...
    'type', 'sphere', 'value', [0, 10], 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');

end



