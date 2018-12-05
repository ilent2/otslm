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

function testFft3(tests)

  % 2-D input
  cim = otslm.tools.visualise(tests.TestData.pattern, 'method', 'fft3');
  
  % 3-D input
  im = zeros(100, 100, 100);
  cim = otslm.tools.visualise(im, 'method', 'fft3');
end

function testOtt(tests)

  cim = otslm.tools.visualise(tests.TestData.pattern, 'method', 'ott');

end

function testRs(tests)

  sz = [10, 10];
  pattern = ones(sz);

  cim = otslm.tools.visualise(pattern, 'method', 'rs', 'z', 10000);
end
