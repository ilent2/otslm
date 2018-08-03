function tests = testvolume2hologram()
  tests = functiontests(localfunctions);
end

function setupOnce(tests)
  addpath('../../');
end

function testVolume2Hologram(tests)

  sz = [100, 100];
  im = ones(sz);
  volume = otslm.tools.hologram2volume(im, 'interpolate', false);
  hologram = otslm.tools.volume2hologram(volume, 'interpolate', false);
  
  [xx, yy] = meshgrid(1:sz(1), 1:sz(2));
  inlens = sqrt((xx-0.5-sz(1)/2).^2 + (yy-0.5-sz(2)/2).^2) <= sz(1)/2;
  
  assert(all(im(inlens) == hologram(inlens)), 'Output does not match');
  
  % Run the test again with interpolation on (coverage)
  hologram = otslm.tools.volume2hologram(volume, 'interpolate', true);

end

function testHologram2Volume(tests)

  sz = [100, 100];
  im = ones(sz);
  volume = otslm.tools.hologram2volume(im, 'interpolate', true);
  volume = otslm.tools.hologram2volume(im, 'interpolate', false);

end
