function tests = testmaksRegion()
  tests = functiontests(localfunctions);
end

function testSimple(tests)

  addpath('../../');
  
  sz = [512, 512];
  b = rand(sz);
  
  p1 = otslm.simple.linear(sz, 10);
  p2 = otslm.simple.linear(sz, -20);
  
  otslm.tools.mask_regions(b, {p1, p2}, {[100, 100], [300, 300]}, ...
      {100, 100});

end
