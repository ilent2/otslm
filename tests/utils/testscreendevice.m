function tests = testscreendevice
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)

  addpath('../../');
  
end

function testSimple(tests)

  slm = otslm.utils.ScreenDevice(1, 'size', [512, 512], 'offset', [100, 0]);
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

function testMonitorPositions(testCase)
  % This test must be run after logging out and back in whenever the
  % display DPI is changed.
  % Make sure all monitors are connected before running Matlab.
  % If a monitor changes, Matlab needs to be restarted.

  javaPositions = otslm.utils.ScreenDevice.getMonitorPositions();
  
  oldUnits = get(0, 'Units');
  set(0, 'Units', 'inches');
  getPositions = get(0, 'MonitorPositions');
  set(0, 'Units', oldUnits);
  
  screenPixelsPerInch = java.awt.Toolkit.getDefaultToolkit().getScreenResolution();
  testCase.verifyEqual(javaPositions, [getPositions .* screenPixelsPerInch] + [1, 1, 0, 0], ...
    'Position from get doesn''t match ScreenDevice positions');
  
end
