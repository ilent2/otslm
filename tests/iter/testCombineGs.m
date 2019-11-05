function tests = testgs
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)
  addpath('../../');
end

function testSimple(testCase)

  sz = [512, 512];
  im1 = otslm.simple.linear(sz, -10);
  im2 = otslm.simple.linear(sz, 10);
  
  components = zeros([sz, 2]);
  components(:, :, 1) = im1;
  components(:, :, 2) = im2;
  
  method = otslm.iter.CombineGerchbergSaxton(components);
  pattern = method.run(2, 'show_progress', false);

end
