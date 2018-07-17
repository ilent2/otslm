% Demonstrate the SLM calibration stuff

% Add the toolbox to the path
addpath('../');

slm = otslm.utils.TestSlm();
cam = otslm.utils.TestCamera(slm);

figure();
plot(slm.linearValueRange(), slm.actualPhaseTable);
ax = gca;
labels = {'actual'};
legend(labels);
title('Comparison of different calibration methods');
xlabel('SLM pixel value');
ylabel('Phase offset');
hold on;

%% Use checkerboard pattern and zeroth order

% Modify the camera to look at the zeroth order
cam.crop(round([cam.size/2, cam.size/4]));

lookuptable_checker = otslm.utils.calibrate(slm, cam, 'method', 'checker');
plot(ax, lookuptable_checker{2}, lookuptable_checker{1});
labels{end+1} = 'checker';
legend(labels);

%% Use Michaelson interfereometer and intensity measurement
lookuptable_michaelson = otslm.utils.calibrate(slm, cam, 'method', 'michaelson');

%% Use sloped michaelson interferometer and interference fringes
lookuptable_smichaelson = otslm.utils.calibrate(slm, cam, 'method', 'smichaelson');

%% Use step function and dark fringe measurement

% Look at the zeroth order
cam.crop(round([cam.size/2, cam.size/4]));

lookuptable_step = otslm.utils.calibrate(slm, cam, 'method', 'step');
plot(ax, lookuptable_step{2}, lookuptable_step{1});
labels{end+1} = 'step';
legend(labels);

%% Use pinholes and interferences fringes
% The performance of this method alone is fairly poor without an initial
% guess for the phase, however the method can be used to characterise
% a device with spatially varying phase.

% Look at the zeroth order
cam.crop(round([cam.size/2, cam.size/4]));

lookuptable_pinholes = otslm.utils.calibrate(slm, cam, 'method', 'pinholes');
plot(ax, lookuptable_pinholes{2}, lookuptable_pinholes{1});
labels{end+1} = 'pinholes';
legend(labels);

%% Use optimisation of linear grating diffraction efficiency

% Move ROI to first order
cam.crop(round([cam.size(1), cam.size(2)/4, 0, cam.size(2)/2 + 10]));

lookuptable_linear = otslm.utils.calibrate(slm, cam, 'method', 'linear');
plot(ax, lookuptable_linear{2}, lookuptable_linear{1});
labels{end+1} = 'linear';
legend(labels);

