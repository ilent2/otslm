function tests = screendevice
  tests = functiontests(localfunctions);
end

function testSimple(tests)

  slm = otslm.utils.ScreenDevice(1, 'target_size', [512, 512], 'target_offset', [100, 0]);
  pattern = otslm.simple.linear(slm.size, 50);
%   slm.show(pattern);
%   pause(2);
%   slm.close();
  
  % Generate images first
  patterns = struct('cdata', {}, 'colormap', {});
  for ii = 1:100
    patterns(ii) = im2frame(otslm.tools.finalize(pattern + ii/100, ...
        'colormap', slm.lookupTable));
  end
  
  % Show the display first (takes longer)
  slm.showRaw(patterns, 'framerate', 100);
  slm.close();

end
