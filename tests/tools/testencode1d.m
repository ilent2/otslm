function tests = testencode1d()
  tests = functiontests(localfunctions);
end

function testSimple(tests)

  addpath('../../');
  
  sz = [512, 512];
  p = otslm.simple.step(sz, 'value', [0, 1]);
  
  otslm.tools.encode1d(p);

end
