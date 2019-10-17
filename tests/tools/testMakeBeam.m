function tests = testMakeBeam()
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)
  addpath('../../');
end

function testPhaseRangeWarning(testCase)

  im = otslm.simple.linear([256, 256], 256);
  testCase.verifyWarning(@() otslm.tools.make_beam(im), ...
      'otslm:tools:make_beam:range');

  im = otslm.simple.linear([256, 256], 256)*2*pi;
  testCase.verifyWarningFree(@() otslm.tools.make_beam(im));

end

function testAmplitudeIgnoredWarning(testCase)

  im = otslm.simple.linear([256, 256], 256)*2*pi;
  amp = zeros(size(im));

  testCase.verifyWarning(@() otslm.tools.make_beam(complex(im), ...
      'amplitude', amp), ...
      'otslm:tools:make_beam:amplitude_ignored');

  testCase.verifyWarningFree(@() otslm.tools.make_beam(im, ...
      'amplitude', amp));

end

