function tests = testBsc2Hologram()
  tests = functiontests(localfunctions);
end

function setupOnce(tests)

  addpath('../../');
  
end

function testCoverage(tests)

  beam = ott.BscPmGauss('NA', 0.96, 'index_medium', 1.0);
  im = otslm.tools.bsc2hologram([512, 512], beam);

end