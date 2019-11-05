function tests = testcombine()
  tests = functiontests(localfunctions);
end

function setupOnce(tests)

  addpath('../../');
  
  sz = [512, 512];
  p1 = otslm.simple.linear(sz, 10);
  p2 = otslm.simple.linear(sz, -10);
  
  tests.TestData.patterns = {p1, p2};

end

function testDefault(tests)
  
  otslm.tools.combine(tests.TestData.patterns);

end

function testDither(tests)
  
  otslm.tools.combine(tests.TestData.patterns, 'method', 'dither');
end

function testSuper(tests)
  
  otslm.tools.combine(tests.TestData.patterns, 'method', 'super');
end

function testRsuper(tests)
  
  otslm.tools.combine(tests.TestData.patterns, 'method', 'rsuper');
end

function testFarfield(tests)

  otslm.tools.combine(tests.TestData.patterns, 'method', 'farfield');
end

function testAdd(tests)
  
  otslm.tools.combine(tests.TestData.patterns, 'method', 'add');
end

function testMultiply(tests)
  
  otslm.tools.combine(tests.TestData.patterns, 'method', 'multiply');
end

function testAddAngle(tests)
  
  otslm.tools.combine(tests.TestData.patterns, 'method', 'addangle');
end

function testAverage(tests)
  
  otslm.tools.combine(tests.TestData.patterns, 'method', 'average');
end