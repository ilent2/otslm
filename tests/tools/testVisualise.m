function tests = testVisualise()
  tests = functiontests(localfunctions);
end

function setupOnce(tests)

  addpath('../../');

  tests.TestData.pattern = ones([512, 512]);
  
end

function testFft(tests)
  cim = otslm.tools.visualise(tests.TestData.pattern, 'method', 'fft');

end

function testOtt(tests)
  cim = otslm.tools.visualise(tests.TestData.pattern, 'method', 'ott');

end

function testRs(tests)

  sz = [10, 10];
  pattern = ones(sz);

  cim = otslm.tools.visualise(pattern, 'method', 'rs', 'z', 10000);
end