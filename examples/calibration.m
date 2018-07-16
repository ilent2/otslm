% Demonstrate the SLM calibration stuff

% Add the toolbox to the path
addpath('../');

slm = otslm.utils.TestSlm();
cam = otslm.utils.TestCamera(slm);

figure();
plot(slm.linearValueRange(), slm.actualPhaseTable);
% plot(linspace(0, 1, length(slm.lookupTable)), slm.lookupTable);  % TODO: Remove this?
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
plot(lookuptable_checker{2}, lookuptable_checker{1});
% plot(linspace(0, 1, length(lookuptable_checker{1})), lookuptable_checker{1});  % TODO: Remove this?
labels{end+1} = 'checker';
legend(labels);

%% Use Michaelson interfereometer and intensity measurement
lookuptable_michaelson = otslm.utils.calibrate(slm, cam, 'method', 'michaelson');

%% Use sloped michaelson interferometer and interference fringes
lookuptable_smichaelson = otslm.utils.calibrate(slm, cam, 'method', 'smichaelson');

%% Use step function and dark fringe measurement
lookuptable_step = otslm.utils.calibrate(slm, cam, 'method', 'step');

%% Use pinholes and interferences fringes
lookuptable_pinholes = otslm.utils.calibrate(slm, cam, 'method', 'pinholes');

%% Use optimisation of linear grating diffraction efficiency
lookuptable_linear = otslm.utils.calibrate(slm, cam, 'method', 'linear');

