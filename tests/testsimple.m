function tests = testsimple
  % tests for otslm.simple.*
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

  pattern = otslm.simple.aperture(sz, 100, 'shape', 'circle');
  testCase.verifyClass(pattern, 'logical', 'wrong type (logical)');
  
  pattern = otslm.simple.aperture(sz, [100, 200], 'shape', 'rect');
  testCase.verifyClass(pattern, 'logical', 'wrong type (logical)');
  
  pattern = otslm.simple.aperture(sz, [100, 200], 'shape', 'ring');
  testCase.verifyClass(pattern, 'logical', 'wrong type (logical)');

  pattern = otslm.simple.aperture(sz, 100, 'value', [0, 1]);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
end

function testAspheric(testCase)
  sz = [512, 512];
  pattern = otslm.simple.aspheric(sz, 10, 0.33);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
end

function testAxicon(testCase)
  sz = [512, 512];
  pattern = otslm.simple.axicon(sz, 1/100);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
end

function testBessel(testCase)
  sz = [512, 512];
  pattern = otslm.simple.bessel(sz, 0);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
end

function testCheckerboard(testCase)
  sz = [512, 512];
  
  pattern = otslm.simple.checkerboard(sz, 'value', [false, true]);
  testCase.verifyClass(pattern, 'logical', 'wrong type (logical)');
  
  pattern = otslm.simple.checkerboard(sz);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
end

function testStripes(testCase)

  sz = [2, 4];
  
  pattern = otslm.simple.stripes(sz, 2, 'value', [false, true]);
  testCase.verifyClass(pattern, 'logical', 'wrong type (logical)');
  
  pattern = otslm.simple.stripes(sz, 2);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  testCase.veifyEqual(pattern, [0.5, 0.5, 0, 0; 0.5, 0.5, 0, 0]);
  
end

function testGaussian(testCase)
  sz = [512, 512];
  pattern = otslm.simple.gaussian(sz, 100);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
end

function testGaussian3d(testCase)
  sz = [128, 128, 128];
  pattern = otslm.simple.gaussian3d(sz, 100);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
end

function testHgmode(testCase)
  sz = [512, 512];
  pattern = otslm.simple.hgmode(sz, 3, 2);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
end

function testIgmode(testCase)
  sz = [512, 512];

  % Test even modes
  pattern = otslm.simple.igmode(sz, true, 4, 2, 1.0);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
end

function testLgmode(testCase)
  sz = [512, 512];
  pattern = otslm.simple.lgmode(sz, -3, 2);
  testCase.verifyClass(pattern, 'double', 'wrong type');
  
  [~, amplitude] = otslm.simple.lgmode(sz, -3, 2);
  testCase.verifyClass(amplitude, 'double', 'wrong type for amplitude');
  
end

function testLinear(testCase)
  % Test single spacing
  pattern = otslm.simple.linear([512, 512], 10);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');

  % Test negative spacing
  pattern1 = otslm.simple.linear([512, 512], 10);
  pattern2 = otslm.simple.linear([512, 512], -10);
  assert(all(pattern1(:) + pattern2(:) == pattern1(1) + pattern2(1)));

  % Test negative spacing with angle
  pattern1 = otslm.simple.linear([512, 512], 10, 'angle_deg', 0);
  pattern2 = otslm.simple.linear([512, 512], -10, 'angle_deg', 0);
  assert(all(pattern1(:) + pattern2(:) == pattern1(1) + pattern2(1)));
  
end

function testLinear3d(testCase)
  % Test single spacing
  pattern = otslm.simple.linear3d([128, 128, 128], 10);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
end

function testGrid(testCase)
  sz = [20, 20];
  [xx, yy, rr, phi] = otslm.simple.grid(sz, 'angle', 0.1);
  testCase.verifyClass(xx, 'double', 'xx invalid');
  testCase.verifyClass(yy, 'double', 'yy invalid');
  testCase.verifyClass(rr, 'double', 'rr invalid');
  testCase.verifyClass(phi, 'double', 'phi invalid');
  
  
end

function testGrid3d(testCase)
  sz = [20, 20, 20];
  [xx, yy, zz, rr, theta, phi] = otslm.simple.grid3d(sz);
  testCase.verifyClass(xx, 'double', 'xx invalid');
  testCase.verifyClass(yy, 'double', 'yy invalid');
  testCase.verifyClass(zz, 'double', 'zz invalid');
  testCase.verifyClass(rr, 'double', 'rr invalid');
  testCase.verifyClass(theta, 'double', 'theta invalid');
  testCase.verifyClass(phi, 'double', 'phi invalid');
end

function testCubic(testCase)
  sz = [512, 512];
  pattern = otslm.simple.cubic(sz);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
end

function testParabolic(testCase)
  sz = [512, 512];
  pattern = otslm.simple.parabolic(sz, [1, 2]);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
end

function testRandom(testCase)
  sz = [512, 512];
  pattern = otslm.simple.random(sz);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
end

function testSinusoid(testCase)
  sz = [512, 512];
  pattern = otslm.simple.sinusoid(sz, 100);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  pattern = otslm.simple.sinusoid(sz, 100, 'type', '1d');
  pattern = otslm.simple.sinusoid(sz, 100, 'type', '2dcart');
  pattern = otslm.simple.sinusoid(sz, [100, 50], 'type', '2dcart');
  
  % Make sure the values are what the comments say they are
  pattern = otslm.simple.sinusoid([1, 10], 100, 'type', '1d');
  x = (1:10) - 10/2;
  exactValue = 0.5 * sin(2*pi/100.*x) + 0.5;
  testCase.verifyEqual(pattern, exactValue);
end

function testSinc(testCase)
  sz = [512, 512];
  pattern = otslm.simple.sinc(sz, 100);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  pattern = otslm.simple.sinc(sz, 100, 'type', '1d');
  pattern = otslm.simple.sinc(sz, 100, 'type', '2dcart');
  pattern = otslm.simple.sinc(sz, [100, 50], 'type', '2dcart');
end

function testSpherical(testCase)
  sz = [512, 512];
  pattern = otslm.simple.spherical(sz, 100);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  pattern = otslm.simple.spherical(sz, 100, 'background', 'random');
  pattern = otslm.simple.spherical(sz, 100, 'background', 'checkerboard');
end

function testStep(testCase)

  sz = [512, 512];

  p1 = otslm.simple.step(sz);
  testCase.verifyClass(p1, 'double', 'wrong type (double)');

  p2 = otslm.simple.step(sz, 'centre', [0, 0], 'angle', pi/2.0, 'value', [0.5, 1]);
  
  sz = [1, 5];
  p3 = otslm.simple.step(sz, 'centre', [2.5, 0], 'value', []);
  testCase.verifyEqual(p3, logical([0, 0, 1, 1, 1]));
end

function testZernike(testCase)
  sz = [512, 512];
  pattern = otslm.simple.zernike(sz, 4, 5);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
end

function testAperture3d(testCase)

  sz = [100, 100, 100];
  radius = 50;
  
  pattern = otslm.simple.aperture3d(sz, radius, ...
    'shape', 'sphere', 'value', []);
  testCase.verifyClass(pattern, 'logical', 'wrong type (logical)');
  
  pattern = otslm.simple.aperture3d(sz, radius, ...
    'shape', 'sphere', 'value', [0, 10]);
  testCase.verifyClass(pattern, 'double', 'wrong type (double)');
  
  % Cube
  pattern = otslm.simple.aperture3d(sz, radius, ...
    'shape', 'cube', 'value', []);
  testCase.verifyClass(pattern, 'logical', 'wrong type (logical)');
  
  % Rect
  pattern = otslm.simple.aperture3d(sz, [50, 40, 30], ...
    'shape', 'rect', 'value', []);
  testCase.verifyClass(pattern, 'logical', 'wrong type (logical)');
  
  % Shell
  pattern = otslm.simple.aperture3d(sz, [40, 50], ...
    'shape', 'shell', 'value', []);
  testCase.verifyClass(pattern, 'logical', 'wrong type (logical)');
  
end

function testAberrationRiMismatch(testCase)

  sz = [512, 512];
  n1 = 1.5;
  n2 = 1.33;
  NA = 1.2;
  alpha = asin(NA/n1);
  pattern = otslm.simple.aberrationRiMismatch(sz, n1, n2, alpha);

end
