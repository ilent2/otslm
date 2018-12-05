% Demonstration of +utils/+imaging scripts
% Used to generate image of the light intensity incident on the SLM

% Add otslm to the path
addpath('../');

% Setup camera and slm objects
slm = otslm.utils.TestSlm();
cam = otslm.utils.TestFarfield(slm);

slm.incident = otslm.simple.gaussian(slm.size, 100);

figure(1);
imagesc(slm.incident);
axis image;
title('Incident illumination');

%% Generate an image of the device using a 1-D scan

im = otslm.utils.imaging.scan1d(slm, cam, 'stride', 10, 'width', 10);

figure(2);
plot(1:length(im), im);
title('1D Scan');

%% Generate an image of the device using a 2-D region scan

im = otslm.utils.imaging.scan2d(slm, cam, ...
    'stride', [50,50], 'width', [50,50]);

figure(3);
imagesc(im);
title('2D Raster Scan');

