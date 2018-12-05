function tests = testgs
  tests = functiontests(localfunctions);
end

function testSimple(tests)

  addpath('../../');

  sz = [256, 256];
  incident = ones(sz);
  target = otslm.simple.aperture(sz, sz(1)/2);

  pattern = otslm.iter.bowman2017(target, ...
    'incident', incident, 'iterations', 2);

end
