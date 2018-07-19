function tests = testdither()
  tests = functiontests(localfunctions);
end

function setupOnce(tests)
  addpath('../../');
  
  tests.TestData.pattern = rand([512, 512]);
end

function testDefault(tests)

  otslm.tools.dither(tests.TestData.pattern, 0.5);

end

function testThreshold(tests)

  otslm.tools.dither(tests.TestData.pattern, 0.5, 'method', 'threshold');
end

function testMdither(tests)

  otslm.tools.dither(tests.TestData.pattern, 0.5, 'method', 'mdither');
end

function testFloyd(tests)

  otslm.tools.dither(tests.TestData.pattern, 0.5, 'method', 'floyd');
end

function testRandom(tests)

  otslm.tools.dither(tests.TestData.pattern, 0.5, 'method', 'random');
end
