function tests = testRedTweezers
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)

  addpath('../../../');
end

function testConstruct(testCase)
  % Check that the file read function works
  
  rt = otslm.utils.RedTweezers.PrismsAndLenses();

end
