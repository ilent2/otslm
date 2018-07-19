function tests = testgs
  tests = functiontests(localfunctions);
end

function testSimple(tests)

  addpath('../../');

  sz = [512, 512];
  incident = ones(sz);

  im = zeros(sz);
  im = insertText(im,[7 0; 0 25] + [ 230, 225 ], {'UQ', 'OMG'}, ...
      'FontSize', 18, 'BoxColor', 'black', 'TextColor', 'white', ...
      'BoxOpacity', 0);
  im = im(:, :, 1);

  pattern = otslm.iter.gs(im, 'incident', incident);

end
