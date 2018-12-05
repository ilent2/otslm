function tests = testLookupTable
  tests = functiontests(localfunctions);
end

function setupOnce(tests)

  addpath('../../');
  tests.TestData.temp_fname = tempname();
  
  phase = linspace(0, 2*pi, 20);
  value = linspace(0, 19, 20);
  tests.TestData.lt = otslm.utils.LookupTable(phase.', value.', 'range', 2*pi);
  
end

function teardownOnce(tests)

  if isfile(tests.TestData.temp_fname)
    delete(tests.TestData.temp_fname);
  end
end

function testSaveLoad(tests)

  fname = tests.TestData.temp_fname;
  lt = tests.TestData.lt;
  
  % Save the table to file
  lt.save(fname);
  
  % Load the lookup table from file
  nlt = otslm.utils.LookupTable.load(fname, 'channels', -1);
  
  % Check the values haven't changed
  assert(all(lt.phase(:) == nlt.phase(:)));
  assert(all(lt.value(:) == nlt.value(:)));
  assert(all(lt.range(:) == nlt.range(:)));
  
end

function testSorted(tests)
  nlt = tests.TestData.lt.sorted();
end

function testLinearised(tests)
  nlt = tests.TestData.lt.linearised(10);
  assert(length(nlt.phase) == 10, 'Wrong number of outputs');
end

function testValueMinimised(tests)
  nlt = tests.TestData.lt.valueMinimised([20]);
end
