function tests = testfinalize()
  tests = functiontests(localfunctions);
end

function setupOnce(tests)

  addpath('../../');
end

function testReturnTypePreservedGray(testCase)

  sz = [512, 512];
  pattern = complex(rand(sz));

  % Apply colour map
  pattern = otslm.tools.colormap(pattern, 'gray');
  
  import matlab.unittest.constraints.IsReal
  testCase.verifyThat(pattern, ~IsReal);
end