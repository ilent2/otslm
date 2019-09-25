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

function testSpots(testCase)

  rt = otslm.utils.RedTweezers.PrismsAndLenses();
  
  testCase.verifyWarningFree(@() rt.addSpot('position', [0, 1, 2]));
  testCase.verifyWarningFree(@() rt.removeSpot());
  
  rt.use_texture = true;
  
  testCase.verifyWarningFree(@() rt.addSpot('position', [0, 1, 2]));
  testCase.verifyWarningFree(@() rt.removeSpot());
  
end
