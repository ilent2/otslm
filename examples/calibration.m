% Demonstrate the SLM calibration stuff

% Add the toolbox to the path
addpath('../');

slm = otslm.utils.TestSlm();
cam = otslm.utils.TestCamera(slm);
inf = otslm.utils.TestMichelson(slm);

vis_target = false;    % True to show target graphs

figure();
plot(slm.linearValueRange(), slm.actualPhaseTable);
ax = gca;
labels = {'actual'};
legend(ax, labels);
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
legend(ax, labels);

%% Use Michelson interfereometer and intensity measurement

% Set no tilt angle
inf.tilt = 0.0;

lookuptable_michelson = otslm.utils.calibrate(slm, inf, 'method', 'michelson');
plot(ax, lookuptable_michelson{2}, lookuptable_michelson{1});
labels{end+1} = 'michelson';
legend(ax, labels);

%% Use sloped michelson interferometer and interference fringes

% Set tilt angle
inf.tilt = 20;

% Generate a figure to of the system
if vis_target
  slm.showComplex(ones(slm.size));
  im = inf.viewTarget();
  figure();
  subplot(1, 2, 1);
  imagesc(im);
  title('Sloped michelson interferometer');
  subplot(1, 2, 2);
  plot(abs(fft(sum(im, 1))));
end

lookuptable_smichelson = otslm.utils.calibrate(slm, inf, ...
    'method', 'smichelson', 'methodargs', {'slice_index', inf.tilt+1});
plot(ax, lookuptable_smichelson{2}, lookuptable_smichelson{1});
labels{end+1} = 'smichelson';
legend(ax, labels);

%% Use step function and dark fringe measurement

% Look at the zeroth order
cam.crop(round([cam.size/2, cam.size/4]));

lookuptable_step = otslm.utils.calibrate(slm, cam, 'method', 'step');
plot(ax, lookuptable_step{2}, lookuptable_step{1});
labels{end+1} = 'step';
legend(ax, labels);

%% Use pinholes and interferences fringes
% The performance of this method alone is fairly poor without an initial
% guess for the phase, however the method could be used to characterise
% a device with spatially varying phase.

% Look at the zeroth order
cam.crop(round([cam.size/2, cam.size/4]));

lookuptable_pinholes = otslm.utils.calibrate(slm, cam, 'method', 'pinholes');
plot(ax, lookuptable_pinholes{2}, lookuptable_pinholes{1});
labels{end+1} = 'pinholes';
legend(ax, labels);

%% Use optimisation of linear grating diffraction efficiency
% This method doesn't seem to work too well, the generated lookup table
% doesn't resemble the target distribution in most cases

% Move ROI to entire screen
cam.crop([]);

% Let's generate a figure to see what it should look like
if vis_target
  figure();
  grating = otslm.simple.linear(slm.size, 10);
  grating = otslm.tools.finalize(grating);
  vis = otslm.tools.visualise(grating, 'padding', 200, 'method', 'fft');
  imagesc(abs(vis));
  title('Visualisation of target');
end

% Location of the zeroth order, from the above figure
loc = [450, 542, 464, 554];

lookuptable_linear = otslm.utils.calibrate(slm, cam, ...
    'method', 'linear', 'methodargs', {'method', 'polynomial', 'dof', 5, ...
    'grating', 'linear', 'location', loc, 'initial_cond', 'rand'});
plot(ax, lookuptable_linear{2}, lookuptable_linear{1});
labels{end+1} = 'linear';
legend(ax, labels);

