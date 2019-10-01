function tests = testLensesAndPrisms()
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)

  addpath('../../');
end

function testSimple(testCase)

  
  sz = [512, 512];
  xyz = randn(3, 5);
  
  pattern = otslm.tools.lensesAndPrisms(sz, xyz);

end
