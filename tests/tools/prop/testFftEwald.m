function tests = testFftEwald()
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)
  addpath('../../../');
end

function testForwardSimple(testCase)

  sz = [256, 256];
  pattern = rand(sz) + 1i*rand(sz);
  
  [result, prop] = otslm.tools.prop.FftEwaldForward.simple(pattern);
  
  testCase.verifyEqual(prop.roi_output, [129, 129, 65, 256, 256, 130], ...
    'Output region of interest incorrect');
  
  testCase.verifyEqual(ndims(result), 3, ...
    'Output should have 3 dimensions');

end

function testInverseSimple(testCase)

  sz = [256, 256, 256];
  pattern = rand(sz) + 1i*rand(sz);
  
  [result, ~] = otslm.tools.prop.FftEwaldInverse.simple(pattern);
  
  testCase.verifyEqual(ndims(result), 2, ...
    'Output should have 2 dimensions');

end

function testForwardBackwardSimple(testCase)
% Check that applying forward + inverse FTT reproduces input

  sz = [256, 256];
%   focal_length = 200;
  focal_length = [];
  pattern = exp(1i*2*pi*otslm.simple.linear(sz, 32));
  
  % We use an amplitude profile that transforms nicely (so we don't
  % get really large errors at the edge of the image).
  pattern = pattern .* otslm.simple.gaussian(sz, 32);
%   pattern = pattern .* otslm.simple.spherical(sz, 128);
  
  % Discard parts of pattern outside lens
  mask = otslm.simple.aperture(sz, sz(1)/2);
  pattern(~mask) = 0.0;
  
  interpolate = false;
  
%   filt = otslm.simple.gaussian3d([3, 3, 3], 2);
%   filt = filt ./ sum(abs(filt(:)));
  filt = [];
  
  [middle, ~] = otslm.tools.prop.FftEwaldForward.simple(pattern, ...
    'interpolate', interpolate, 'focal_length', focal_length, ...
    'convfilt', filt);
  
  [result, ~] = otslm.tools.prop.FftEwaldInverse.simple(middle, ...
    'interpolate', interpolate, 'focal_length', focal_length);
  
%   disp(['Size middle: ' num2str(size(middle, 3))]);
%   figure(), plot(abs(pattern(end/2, :)).'); hold on; plot(abs(result(end/2, :)).');
  
  import matlab.unittest.constraints.IsEqualTo;
  import matlab.unittest.constraints.AbsoluteTolerance;
  import matlab.unittest.constraints.RelativeTolerance;
  abstol = 1.0e-2;  reltol = 1e-2;
  testCase.verifyThat(pattern, IsEqualTo(result, ...
      'Within', AbsoluteTolerance(abstol) | RelativeTolerance(reltol) ));

end
