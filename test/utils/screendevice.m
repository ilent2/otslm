function tests = screendevice
  tests = functiontests(localfunctions);
end

function testSimple(tests)

  slm = otslm.utils.ScreenDevice(1);
  pattern = otslm.simple.linear(slm.size, 50);
  slm.show(pattern);
  pause(2);
  slm.close();
  
  % Generate images first
  patterns = {};
  for ii = 1:100
    patterns{ii} = pattern + ii/100;
    patterns{ii} = otslm.tools.finalize(patterns{ii}, ...
        'colormap', slm.lookupTable);
  end
  
  % Show the display first (takes longer)
  slm.showRaw();
  
  for ii = 1:length(patterns)
    slm.showRaw(patterns{ii});
%     pause(0.01);
  end
  slm.close();

end
