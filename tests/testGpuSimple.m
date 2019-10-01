function tests = testGpuSimple
  % SIMPLE tests for otslm.simple.*
  %
  % These tests are primarily to test everything runs, we should
  % write better tests in future.

  tests = functiontests(localfunctions);
end

function setupOnce(testCase)
  addpath('../');

  % Check if there is a GPU (sometimes fails if run more than once???)
  b = parallel.gpu.GPUDevice.isAvailable;

end

function testAperture(testCase)
  sz = [512, 512];
  
  pattern = otslm.simple.aperture(sz, 100, 'shape', 'square', 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testAspheric(testCase)
  sz = [512, 512];
  
  pattern = otslm.simple.aspheric(sz, 10, 0.33, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testAxicon(testCase)
  sz = [512, 512];
  
  pattern = otslm.simple.axicon(sz, 1/100, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testBessel(testCase)
  sz = [512, 512];
  
  pattern = otslm.simple.bessel(sz, 0, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testCheckerboard(testCase)
  sz = [512, 512];
  
  pattern = otslm.simple.checkerboard(sz, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testGaussian(testCase)
  sz = [512, 512];
  
  pattern = otslm.simple.gaussian(sz, 100, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testHgmode(testCase)
  sz = [512, 512];
  
  pattern = otslm.simple.hgmode(sz, 3, 2, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testIgmode(testCase)
  sz = [512, 512];

  % Test odd modes
  pattern = otslm.simple.igmode(sz, false, 4, 2, 1.0, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testLgmode(testCase)
  sz = [512, 512];
  
  pattern = otslm.simple.lgmode(sz, -3, 2, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
  
  [~, amplitude] = otslm.simple.lgmode(sz, -3, 2, 'gpuArray', true);
  testCase.verifyClass(amplitude, 'gpuArray', 'wrong type for amplitude');
end

function testLinear(testCase)
  sz = [512, 512];

  % Test multiple spacings for different directions
  pattern = otslm.simple.linear([512, 512], [10, 20], 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testGrid(testCase)
  sz = [512, 512];
  
  [xx, yy, rr, phi] = otslm.simple.grid(sz, 'angle', 0.1, 'gpuArray', true);
  testCase.verifyClass(xx, 'gpuArray', 'xx invalid');
  testCase.verifyClass(yy, 'gpuArray', 'yy invalid');
  testCase.verifyClass(rr, 'gpuArray', 'rr invalid');
  testCase.verifyClass(phi, 'gpuArray', 'phi invalid');
end

function testCubic(testCase)
  sz = [512, 512];
  
  pattern = otslm.simple.cubic(sz, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testParabolic(testCase)
  sz = [512, 512];
  
  pattern = otslm.simple.parabolic(sz, [1, 2], 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testRandom(testCase)
  sz = [512, 512];
  
  pattern = otslm.simple.random(sz, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
  
  pattern = otslm.simple.random(sz, 'type', 'gaussian');
  pattern = otslm.simple.random(sz, 'type', 'binary');
end

function testSinusoid(testCase)
  sz = [512, 512];
  
  pattern = otslm.simple.sinusoid(sz, 100, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testSinc(testCase)
  sz = [512, 512];
  
  pattern = otslm.simple.sinc(sz, 100, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testSpherical(testCase)
  sz = [512, 512];
  
  pattern = otslm.simple.spherical(sz, 100, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testStep(testCase)
  sz = [512, 512];

  p3 = otslm.simple.step(sz, 'angle_deg', 45.0, 'gpuArray', true);
  testCase.verifyClass(p3, 'gpuArray', 'wrong type (gpu)');

end

function testZernike(testCase)
  sz = [512, 512];
  
  pattern = otslm.simple.zernike(sz, 4, 5, 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');
end

function testAperture3d(testCase)

  sz = [100, 100, 100];
  radius = 50;
  
  pattern = otslm.simple.aperture3d(sz, radius, ...
    'shape', 'sphere', 'value', [0, 10], 'gpuArray', true);
  testCase.verifyClass(pattern, 'gpuArray', 'wrong type (gpu)');

end


