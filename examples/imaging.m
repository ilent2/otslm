% Demonstration of +utils/image_device script to generate
% images of the light intensity incident on the SLM

% Add otslm to the path
addpath('../');

% Setup camera and slm objects
slm = otslm.utils.TestSlm();
cam = otslm.utils.TestCamera(slm);

slm.incident = otslm.simple.gaussian(slm.size, 100);

figure(1);
imagesc(slm.incident);

%% Generate an image of the device using a 1-D scan
im = otslm.utils.image_device(slm, cam, 'method', 'scan1d', ...
  'methodargs', {'stride', 10, 'width', 10});

figure(2);
plot(1:length(im), im);

%% Generate an image of the device using a 2-D region scan

im = otslm.utils.image_device(slm, cam, 'method', 'scan2d', ...
  'methodargs', {'stride', [50,50], 'width', [50,50]});

figure(3);
imagesc(im);
