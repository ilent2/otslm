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

function testMatchCombineOutput(testCase)

  sz = [100, 100];
  cn = sz / 2;
  xyz = [10, 5, 0.1; -3, -2, -0.2] ./ sz(1);
  
  pattern = otslm.tools.lensesAndPrisms(sz, xyz.');
  
  g1 = otslm.simple.linear(sz, 1./xyz(1, 1:2), 'centre', cn);
  g2 = otslm.simple.linear(sz, 1./xyz(2, 1:2), 'centre', cn);
  l1 = otslm.simple.parabolic(sz, xyz(1, 3), 'centre', cn);
  l2 = otslm.simple.parabolic(sz, xyz(2, 3), 'centre', cn);
  
  target = otslm.tools.combine({mod(l1+g1, 1), mod(l2+g2, 1)}, 'method', 'super');
  
  testCase.verifyEqual(abs(0.5 - mod(pattern-target, 1)), zeros(sz), 'AbsTol', 0.02);
end
