function tests = testvolume2hologram()
  tests = functiontests(localfunctions);
end

function setupOnce(tests)
  addpath('../../');
end

function testVolume2Hologram(testCase)

  import matlab.unittest.constraints.IsEqualTo;
  import matlab.unittest.constraints.AbsoluteTolerance;
  abstol = 1.0e-6;

  sz = [100, 100];
  im = ones(sz);
  volume = otslm.tools.hologram2volume(im, 'interpolate', false);
  hologram = otslm.tools.volume2hologram(volume, 'interpolate', false);
  
  [xx, yy] = meshgrid(1:sz(1), 1:sz(2));
  inlens = sqrt((xx-0.5-sz(1)/2).^2 + (yy-0.5-sz(2)/2).^2) <= sz(1)/2;
  
  testCase.verifyThat(im(inlens), IsEqualTo(hologram(inlens), ...
      'Within', AbsoluteTolerance(abstol)), ...
      'Output does not match');
    
  volume = otslm.tools.hologram2volume(im, 'interpolate', true);
  hologram = otslm.tools.volume2hologram(volume, 'interpolate', true);
  
  flattened = sum(volume, 3);
  
  testCase.verifyThat(flattened(inlens), IsEqualTo(im(inlens), ...
      'Within', AbsoluteTolerance(abstol)), ...
      'Output with summation does not match');
  
  testCase.verifyThat(hologram(inlens), IsEqualTo(im(inlens), ...
      'Within', AbsoluteTolerance(abstol)), ...
      'Output with interpolation does not match');
  
  % Run the test again with interpolation on (coverage)
  %hologram = otslm.tools.volume2hologram(volume, 'interpolate', true);

end

function testHologram2Volume(tests)

  sz = [100, 100];
  im = ones(sz);
  volume = otslm.tools.hologram2volume(im, 'interpolate', true);
  volume = otslm.tools.hologram2volume(im, 'interpolate', false);

end
