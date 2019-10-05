function tests = testOtt()
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)
  addpath('../../../');
end

function testForwardSimple(testCase)

  sz = [200, 200];
  pattern = rand(sz) + 1i*rand(sz);
  
  [beam, prop] = otslm.tools.prop.OttForward.simple(pattern);
  
  testCase.verifyInstanceOf(beam, 'ott.Bsc', ...
    'Did not return a beam object');
  
  testCase.verifyEqual(prop.size, sz, ...
    'Region of interest incorrect');

end

function testForwardSimpleImage(testCase)

  sz = [200, 200];
  pattern = rand(sz) + 1i*rand(sz);
  
  [output, prop] = otslm.tools.prop.Ott2Forward.simple(pattern);
  
  testCase.verifyInstanceOf(output, 'double', ...
    'Did not return a beam object');
  
  testCase.verifyEqual(prop.size, sz, ...
    'Region of interest incorrect');

end

