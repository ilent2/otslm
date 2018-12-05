function tests = testPhaseBlur()
  tests = functiontests(localfunctions);
end

function setupOnce(tests)

  addpath('../../');
  
end

function testCoverage(tests)

  im = otslm.simple.linear([20, 20], 10);
  im = otslm.tools.phaseblur(im);

end