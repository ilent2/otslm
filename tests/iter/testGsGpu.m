function tests = testGsGpu
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)
  addpath('../../');

  % Check if there is a GPU (sometimes fails if run more than once???)
  b = parallel.gpu.GPUDevice.isAvailable;

end

function testTargetGpu(testCase)

  sz = [512, 512];
  target = otslm.simple.aperture(sz, sz(1)/2, 'gpuArray', true);

  method = otslm.iter.GerchbergSaxton(target);
  pattern = method.run(2, 'show_progress', false);
  
  testCase.verifyClass(pattern, 'gpuArray', 'run returned wrong type');
  testCase.verifyClass(method.guess, 'gpuArray', 'guess has wrong type');
  testCase.verifyClass(method.target, 'gpuArray', 'target has wrong type');
end

function testTargetDouble(testCase)

  sz = [512, 512];
  target = otslm.simple.aperture(sz, sz(1)/2, 'gpuArray', false);

  method = otslm.iter.GerchbergSaxton(target, 'gpuArray', true);
  pattern = method.run(2, 'show_progress', false);
  
  testCase.verifyClass(pattern, 'gpuArray', 'run returned wrong type');
  testCase.verifyClass(method.guess, 'gpuArray', 'guess has wrong type');
  testCase.verifyClass(method.target, 'gpuArray', 'target has wrong type');
end