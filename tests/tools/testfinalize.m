function tests = testfinalize()
  tests = functiontests(localfunctions);
end

function setupOnce(tests)

  addpath('../../');
end


function testSimple(tests)
  
  sz = [512, 512];
  p = otslm.simple.linear(sz, 10);
  
  fp = otslm.tools.finalize(p);

end

function testColormap(tests)
  
  sz = [512, 512];
  p = otslm.simple.linear(sz, 10);

  colormap = otslm.utils.LookupTable(linspace(0, 1, 100).', ...
    linspace(0, 2*pi, 100).', 'range', 2*pi);
  
  fp = otslm.tools.finalize(p, 'colormap', colormap);

end

function testRpack(tests)

  sz = [512, 512];
  a = rand(sz);
  
  fp = otslm.tools.finalize([], 'amplitude', a, 'rpack', '45deg');
end

function testDmd(tests)

  sz = [512, 512];
  a = rand(sz);
  
  fp = otslm.tools.finalize([], 'device', 'dmd', 'amplitude', a);

end