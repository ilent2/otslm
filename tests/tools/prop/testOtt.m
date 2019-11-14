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

function testTwoChannelInput(testCase)
  % If two channels are provided, we should ignore the polarisation input
  
  sz = [200, 200];
  pattern = rand(sz) + 1i*rand(sz);
  
  % Check with one input
  [output1, prop1] = otslm.tools.prop.Ott2Forward.simple(pattern, ...
    'polarisation', [1, 0]);
  
  pattern(:, :, 2) = 0;
  
  % Check with two inputs
  [output2, prop2] = otslm.tools.prop.Ott2Forward.simple(pattern, ...
    'polarisation', [0, 0]);
  
  testCase.verifyEqual(prop1.size, prop2.size, ...
    'Propagators size don''t match');
  
  testCase.verifyEqual(output1, output2, ...
    'One and two channel inputs don''t match');
  
end

