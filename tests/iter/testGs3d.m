function tests = testGs3d
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)
  addpath('../../');
end

function testSimple(testCase)

  import matlab.unittest.constraints.IsEqualTo;

  sz = [128, 128, 128];
  target = otslm.simple.aperture3d(sz, sz(1)/8);

  method = otslm.iter.GerchbergSaxton3d(target);
  pattern = method.run(2, 'show_progress', false);
  
  testCase.verifyThat(size(pattern), ...
    IsEqualTo(sz(1:2)), 'Patter size incorrect');

end
