function tests = testRedTweezers
  tests = functiontests(localfunctions);
end

function setupOnce(testCase)

  addpath('../../../');
end

function testConstruct(testCase)
  % Check that the file read function works
  
  rt = otslm.utils.RedTweezers.RedTweezers();

end

function testFileRead(testCase)
  % Check that the file read function works
  
  test_string = 'This is a test string';
  filename = tempname();
  
  % Generate test file
  fid = fopen(filename, 'w');
  fprintf(fid, test_string);
  fclose(fid);
  
  content = otslm.utils.RedTweezers.RedTweezers.readGlslFile(filename);
  
  testCase.verifyEqual(content, test_string, ...
    'Read content does not match');

end
