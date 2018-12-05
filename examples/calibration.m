% Demonstrate the SLM calibration stuff
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Add the toolbox to the path
addpath('../');

% Create the phase table
value = linspace(0, 255, 256);

table_type = 'linear';
switch table_type
  case 'linear'
    phase = linspace(0, 2*pi, 256);
    
  case 'example1'
    table = polyval([0.7, -1.9, 1.5, -0.02]*20, linspace(0, 1, 256));
  case 'example2'
    table = polyval([0.9, -1.9, 1.7, -0.02]*10, linspace(0, 1, 256));
  case 'example3'
    table = 2*sin(linspace(0, 1, 256)*2*pi) + 7*linspace(0, 1, 256);
  otherwise
    error('Unknown phase table type string');
end
lookup_table = otslm.utils.LookupTable(phase.', value.');

slm = otslm.utils.TestSlm('lookup_table', lookup_table);
cam = otslm.utils.TestFarfield(slm);
inf = otslm.utils.TestMichelson(slm);

vis_target = false;    % True to show target graphs

figure();
plot(lookup_table.value, lookup_table.phase);
ax = gca;
labels = {'Actual'};
legend(ax, labels, 'Location', 'NorthWest');
title('Comparison of different calibration methods');
xlabel('Value');
ylabel('Phase');
hold on;

%% Use checkerboard pattern and zeroth order
% This method sometimes identifies the phase as having the incorrect sign,
% but otherwise it seems pretty good.

lookuptable_checker = otslm.utils.calibration.checker(slm, cam, ...
  'stride', 8, 'verbose', true);
plot(ax, lookuptable_checker.value, lookuptable_checker.phase);
labels{end+1} = 'Checker';
legend(ax, labels);

%% Use Michelson interfereometer and intensity measurement

% Set no tilt angle
inf.tilt = 0.0;

lookuptable_michelson = otslm.utils.calibration.michelson(slm, inf, ...
  'stride', 8, 'verbose', true);
plot(ax, lookuptable_michelson.value, lookuptable_michelson.phase);
labels{end+1} = 'Michelson';
legend(ax, labels);

%% Use sloped michelson interferometer and interference fringes
% This method is much easier to user with the graphical interface

% Set tilt angle
inf.tilt = 20;

lookuptable_smichelson = otslm.utils.calibration.smichelson(slm, inf, ...
    'stride', 8, 'verbose', true, ...
    'slice1_offset', -10, 'slice2_offset', 10, ...
    'slice1_width', 5, 'slice2_width', 5, ...
    'slice_angle', 0, 'freq_index', 29, 'step_angle', 90);
plot(ax, lookuptable_smichelson.value, lookuptable_smichelson.phase);
labels{end+1} = 'Sloped Michelson';
legend(ax, labels);

%% Use step function and dark fringe measurement

lookuptable_step = otslm.utils.calibration.step(slm, cam, ...
  'stride', 8, 'verbose', true, 'step_angle', 0, ...
  'show_spectrum', false, 'freq_index', 200);
plot(ax, lookuptable_step.value, lookuptable_step.phase);
labels{end+1} = 'Step';
legend(ax, labels);

%% Use pinholes and interferences fringes
% The performance of this method alone is fairly poor without an initial
% guess for the phase, however the method could be used to characterise
% a device with spatially varying phase.

lookuptable_pinholes = otslm.utils.calibration.pinholes(slm, cam, ...
  'stride', 8, 'verbose', true, ...
  'slice_angle', 0, 'slice_width', 10, ...
  'show_spectrum', false, 'freq_index', 200, ...
  'radius', 10);
plot(ax, lookuptable_pinholes.value, lookuptable_pinholes.phase);
labels{end+1} = 'Pinholes';
legend(ax, labels);
