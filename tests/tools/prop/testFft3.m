function tests = testFft3()
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)
  addpath('../../../');
end

function testForwardSimple(testCase)

  sz = [256, 256, 256];
  pattern = rand(sz) + 1i*rand(sz);
  
  [result, prop] = otslm.tools.prop.Fft3Forward.simple(pattern);
  
  testCase.verifyEqual(prop.roi, [129, 129, 129, 256, 256, 256], ...
    'Region of interest incorrect');
  
  testCase.verifyEqual(prop.roi_output, prop.roi, ...
    'Region of interest incorrect');
  
  testCase.verifyEqual(size(result), size(pattern), ...
    'Output size should match input size');

end

function testInverseSimple(testCase)

  sz = [256, 256, 256];
  pattern = rand(sz) + 1i*rand(sz);
  
  [result, prop] = otslm.tools.prop.Fft3Inverse.simple(pattern);
  
  testCase.verifyEqual(prop.roi, [129, 129, 129, 256, 256, 256], ...
    'Region of interest incorrect');
  
  testCase.verifyEqual(prop.roi_output, prop.roi, ...
    'Region of interest incorrect');
  
  testCase.verifyEqual(size(result), size(pattern), ...
    'Output size should match input size');

end

function testForwardBackwardSimple(testCase)
% Check that applying forward + inverse FTT reproduces input

  sz = [256, 256, 256];
  pattern = exp(1i*2*pi*otslm.simple.linear3d(sz, 32));
  
  % We use an amplitude profile that transforms nicely (so we don't
  % get really large errors at the edge of the image).
  pattern = pattern .* otslm.simple.gaussian3d(sz, 32);
  
  [middle, ~] = otslm.tools.prop.Fft3Forward.simple(pattern);
  
  [result, ~] = otslm.tools.prop.Fft3Inverse.simple(middle);
  
  import matlab.unittest.constraints.IsEqualTo;
  import matlab.unittest.constraints.AbsoluteTolerance;
  abstol = 1.0e-4;
  testCase.verifyThat(pattern, IsEqualTo(result, ...
      'Within', AbsoluteTolerance(abstol)));

end
