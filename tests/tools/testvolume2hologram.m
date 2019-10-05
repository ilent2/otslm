function tests = testvolume2hologram()
  tests = functiontests(localfunctions);
end

function setupOnce(tests)
  addpath('../../');
end

function runTestWithParameters(testCase, name, varargin)

  import matlab.unittest.constraints.IsEqualTo;
  import matlab.unittest.constraints.AbsoluteTolerance;
  abstol = 1.0e-6;

  sz = [100, 100];
  im = complex(ones(sz));
  
  [xx, yy] = meshgrid(1:sz(1), 1:sz(2));
  inlens = sqrt((xx-0.5-sz(1)/2).^2 + (yy-0.5-sz(2)/2).^2) <= sz(1)/2;
    
  volume = otslm.tools.hologram2volume(im, varargin{:});
  hologram = otslm.tools.volume2hologram(volume, varargin{:});
  
%   figure(), plot([abs(hologram(end/2, :)).', abs(im(end/2, :)).']);
%   title([name, ': inv']);
  
  testCase.verifyThat(hologram(inlens), IsEqualTo(im(inlens), ...
      'Within', AbsoluteTolerance(abstol)), ...
      [name, ': output does not match']);
  
  flattened = sum(volume, 3);
  
%   figure(), plot([abs(flattened(end/2, :)).', abs(im(end/2, :)).']);
%   title([name, ': sum']);
  
  testCase.verifyThat(flattened(inlens), IsEqualTo(im(inlens), ...
      'Within', AbsoluteTolerance(abstol)), ...
      [name, ': output with sum does not match']);
end

function testDefault(testCase)

  runTestWithParameters(testCase, 'interp focal_length', ...
    'interpolate', true);
  
  runTestWithParameters(testCase, 'no-interp focal_length', ...
    'interpolate', false);

end

function testFocalLength(testCase)

  runTestWithParameters(testCase, 'interp focal_length', ...
    'interpolate', true, 'focal_length', 256);
  
  runTestWithParameters(testCase, 'no-interp focal_length', ...
    'interpolate', false, 'focal_length', 256);
  
end

function testHologram2Volume(tests)

  sz = [100, 100];
  im = ones(sz);
  volume = otslm.tools.hologram2volume(im, 'interpolate', true);
  volume = otslm.tools.hologram2volume(im, 'interpolate', false);

end
