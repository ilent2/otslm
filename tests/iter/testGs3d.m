function tests = testgs
  tests = functiontests(localfunctions);
end

function testSimple(tests)

  addpath('../../');

  sz = [128, 128, 128];
  incident = ones(sz(1:2));
  target = otslm.simple.aperture3d(sz, sz(1)/8);

  method = otslm.iter.GerchbergSaxton3d(target, ...
    'visdata', {'incident', incident, 'NA', 0.1, 'zsize', sz(3)}, ...
    'invdata', {'NA', 0.1});
  pattern = method.run(2, 'show_progress', false);
  
  assert(all(size(pattern) == sz(1:2)), 'Patter size incorrect');

end
