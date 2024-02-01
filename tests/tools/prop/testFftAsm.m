function tests = testFftAsm()
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)
  addpath('../../../');
end

function testForwardSimple(testCase)

  sz = [512, 512];
  pattern = rand(sz) + 1i*rand(sz);
  
  [result, prop] = otslm.tools.prop.FftAsmForward.simple(pattern);
  
  testCase.verifyEqual(prop.roi, [257, 257, 512, 512], ...
    'Region of interest incorrect');
  
  testCase.verifyEqual(prop.roi_output, prop.roi, ...
    'Region of interest incorrect');
  
  testCase.verifyEqual(size(result), size(pattern), ...
    'Output size should match input size');

end

function testInverseSimple(testCase)

  sz = [512, 512];
  pattern = rand(sz) + 1i*rand(sz);
  
  [result, prop] = otslm.tools.prop.FftAsmInverse.simple(pattern);
  
  testCase.verifyEqual(prop.roi, [257, 257, 512, 512], ...
    'Region of interest incorrect');
  
  testCase.verifyEqual(prop.roi_output, prop.roi, ...
    'Region of interest incorrect');
  
  testCase.verifyEqual(size(result), size(pattern), ...
    'Output size should match input size');

end

function testForwardBackwardSimple_axial(testCase)
% Check Inverse and Forward are reciprical (with axial offset)

  z = 10;

  sz = [512, 512];
  pattern = exp(1i*2*pi*otslm.simple.linear(sz, 64));
  
  % We use an amplitude profile that transforms nicely (so we don't
  % get really large errors at the edge of the image).
  pattern = pattern .* otslm.simple.gaussian(sz, 64);
  
  [middle, ~] = otslm.tools.prop.FftAsmForward.simple(pattern, ...
    'axial_offset', z);
  
  [result, ~] = otslm.tools.prop.FftAsmInverse.simple(middle, ...
    'axial_offset', z);

  figure()
  subplot(1, 3, 1);
  imagesc(abs(pattern).^2)
  subplot(1, 3, 2);
  imagesc(abs(middle).^2)
  subplot(1, 3, 3);
  imagesc(abs(result).^2)
  
  import matlab.unittest.constraints.IsEqualTo;
  import matlab.unittest.constraints.AbsoluteTolerance;
  abstol = 1.0e-4;
  testCase.verifyThat(pattern, IsEqualTo(result, ...
      'Within', AbsoluteTolerance(abstol)));

end
