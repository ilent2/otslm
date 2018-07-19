function tests = testSpatialFilter()
  tests = functiontests(localfunctions);
end

function testSimple(tests)

  addpath('../../');
  
  sz = [512, 512];
  p = rand(sz);
  
  aperture = otslm.simple.aperture(sz, 100);
  
  im = otslm.tools.spatial_filter(p, aperture);

end
