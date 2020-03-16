function tests = testdmd
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)
  addpath('../../');
end

function testSimple(testCase)

  slm = otslm.utils.TestDmd();
  pattern = otslm.simple.sinusoid(slm.size, 10, ...
      'type', '1d', 'aspect', 2.0);
  slm.show(pattern);
  
  testCase.verifyNotEqual(size(slm.pattern), slm.size, ...
    'Pattern size should change when using rpack');

  cam = otslm.utils.TestFarfield(slm);
  im = cam.viewTarget();

end

function testNoRpack(testCase)

  sz = [512, 512];
  slm = otslm.utils.TestDmd('size', sz, 'use_rpack', false);
  
  slm.show(zeros(sz));
  
  testCase.verifyEqual(size(slm.pattern), sz, ...
    'Pattern size should not change when not using rpack');
end
