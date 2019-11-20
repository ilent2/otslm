function tests = testBsc
  tests = functiontests(localfunctions);
end

function setupOnce(tests)
  addpath('../../');
end

function testSimple(tests)

  % Describe the incident illumination
  incident = ones(128, 128);

  % Generate the target pattern
  sz = [60, 30, 30];
  dimensions = [5, 20, 5];
  target = otslm.simple.aperture3d(sz, dimensions, ...
      'shape', 'rect', 'value', [0,1]);

  % Objective function for optimisation
  objective = otslm.iter.objectives.Bowman2017('scale', 9, ...
    'field', 'amplitude');

  % Run the method
  [pattern, beam, coeffs] = otslm.iter.bsc(size(incident), target, ...
      'incident', incident, 'objective', objective, ...
      'verbose', true, 'basis_size', 2, 'pixel_size', 2e-07, ...
      'radius', 2.0, 'guess', 'rand');

end
