function tests = testSimulatedAnnealing
  tests = functiontests(localfunctions);
end

function testSimple(tests)

  addpath('../../');

  sz = [512, 512];
  incident = ones(sz);
  target = otslm.simple.aperture(sz, sz(1)/2);

  method = otslm.iter.SimulatedAnnealing(target, ...
    'visdata', {'incident', incident});
  pattern = method.run(2, 'show_progress', false);

end
