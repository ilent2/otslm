function tests = testviewable()
  tests = functiontests(localfunctions);
end

function testcrop(tests)

  addpath('../../');
  
  slm = otslm.utils.TestSlm();
  cam = otslm.utils.TestFarfield(slm);

  % Add a crop region
  cam.crop([100, 100, 100, 100]);
  
  im = cam.viewTarget();
  assert(all(size(im) == [100, 100]), 'Image size incorrect (1)');
  
  % Add two crop regions
  cam.crop({[100, 100, 100, 100], [1, 2, 3, 4]});
  
  im = cam.viewTarget('roi', 2);
  assert(all(size(im) == [4, 3]), 'Image size incorrect (2)');
  
  % Clear the crop region
  cam.crop([]);
  
  im = cam.viewTarget();
  assert(all(size(im) == cam.size), 'Image size incorrect (3)');

end