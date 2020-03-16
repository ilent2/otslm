function tests = testHadamard
  % tests for otslm.simple.hadamard

  tests = functiontests(localfunctions);
end

function setupOnce(testCase)
  addpath('../../');
end

function testSquare(testCase)

  % Expected output with 2x2, index 2, 2
  target = [0, 1; 1, 0];
  
  pattern = otslm.simple.hadamard([2, 2], 2, 2);
  
  testCase.verifyEqual(pattern, target, ...
    'Square 2x2 pattern mismatch');
end

function testNonSquare(testCase)

  % Expected output: no scaling, just padding on the bottom
  target = [0, 1; 1, 0; NaN, NaN];
  
  pattern = otslm.simple.hadamard([3, 2], 2, 2, ...
    'padding_value', NaN);
  
  testCase.verifyEqual(pattern, target, ...
    'Non-square sz with padding');
end

function testRotatedNonSquare(testCase)

  % Expected output: no scaling, just padding on the bottom
  target = [1, 0; 0, 1; NaN, NaN];
  
  pattern = otslm.simple.hadamard([3, 2], 2, 2, ...
    'padding_value', NaN, 'angle', pi/2);
  
  testCase.verifyEqual(pattern, target, ...
    'Non-square sz with padding and rotation');
end

function testLinearMatchesSquareLargeToSmall(testCase)

  pattern1 = otslm.simple.hadamard([10, 10], 3, 4, ...
    'indexing', 'linear', 'order', 'largetosmall');
  
  pattern2 = otslm.simple.hadamard([10, 10], 3, 4, ...
    'indexing', 'square', 'order', 'largetosmall');

  testCase.verifyEqual(pattern1, pattern2, ...
    'linear and square indexing don''t match with orders');
  
end
