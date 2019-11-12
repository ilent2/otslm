function tests = testFft2()
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)
  addpath('../../../');
end

function testForwardSimple(testCase)

  sz = [512, 512];
  pattern = rand(sz) + 1i*rand(sz);
  
  [result, prop] = otslm.tools.prop.FftDebyeForward.simple(pattern);
  
  testCase.verifyEqual(prop.roi, [257, 257, 512, 512], ...
    'Region of interest incorrect');
  
  testCase.verifyEqual(prop.roi_output, prop.roi, ...
    'Region of interest incorrect');
  
  testCase.verifyEqual(size(result), [size(pattern), 3], ...
    'Output size should match input size');

end

function testParaxialLimit(testCase)

  sz = [512, 512];
  pattern = exp(1i*2*pi*otslm.simple.linear(sz, 64, 'angle_deg', 45));
  pattern = pattern .* otslm.simple.gaussian(sz, 64);
  
  % Generate target
  [target, ~] = otslm.tools.prop.FftForward.simple(pattern);

  % Generate test
  [test, ~] = otslm.tools.prop.FftDebyeForward.simple(pattern, ...
    'NA', 0.1, 'radius', 512);
  
%   fudge = -1./0.888898325805562;
%   test = test .* fudge;
  
  targetAbs = abs(target.^2);
  testAbs = abs(sum(test.^2, 3));
  
  % We should remove/fix this in future
  targetAbs = targetAbs ./ max(targetAbs(:));
  testAbs = testAbs ./ max(testAbs(:));
  
%   figure();
%   subplot(1, 2, 1);
%   imagesc(testAbs);
%   subplot(1, 2, 2);
%   imagesc(targetAbs);
  
  import matlab.unittest.constraints.IsEqualTo;
  import matlab.unittest.constraints.AbsoluteTolerance;
  abstol = 1.0e-4;
  testCase.verifyThat(testAbs, IsEqualTo(targetAbs, ...
      'Within', AbsoluteTolerance(abstol)));
end
