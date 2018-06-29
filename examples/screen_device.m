% Demonstration of the screen device class (used to control SLM/DMDs)

slm = otslm.utils.ScreenDevice(1, 'target_size', [512, 512], ...
  'target_offset', [100, 0]);

%% Generate a simple pattern and who
pattern = otslm.simple.linear(slm.size, 50);
slm.show(pattern);
pause(2);
slm.close();

%% Generate a movie of images

% Generate images first
patterns = struct('cdata', {}, 'colormap', {});
for ii = 1:100
  patterns(ii) = im2frame(otslm.tools.finalize(pattern + ii/100, ...
      'colormap', slm.lookupTable));
end

% Show the display first (takes longer)
slm.showRaw(patterns, 'framerate', 100);
slm.close();

