function tests = testSampleRegion()
  tests = functiontests(localfunctions);
end

function setupOnce(tests)

  addpath('../../');
end

function testSimple(tests)
  
  sz = [512, 512];
  
  im = otslm.tools.sample_region(sz, {[100, 100], [300, 300]}, ...
      {[100, 100], [50, 50]});
    
end

function testStep(tests)
  
  sz = [512, 512];
  
  im = otslm.tools.sample_region(sz, {[100, 100], [300, 300]}, ...
      {[100, 100], [50, 50]}, 'amplitude', 'step');
    
end

function testGdither(tests)
  
  sz = [512, 512];
  
  im = otslm.tools.sample_region(sz, {[100, 100], [300, 300]}, ...
      {[100, 100], [50, 50]}, 'amplitude', 'gaussian_dither');
    
end

function testGnoise(tests)
  
  sz = [512, 512];
  
  im = otslm.tools.sample_region(sz, {[100, 100], [300, 300]}, ...
      {[100, 100], [50, 50]}, 'amplitude', 'gaussian_noise');
    
end

function testGscale(tests)
  
  sz = [512, 512];
  
  im = otslm.tools.sample_region(sz, {[100, 100], [300, 300]}, ...
      {[100, 100], [50, 50]}, 'amplitude', 'gaussian_scale');
    
end
