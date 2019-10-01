% Demonstration of 3-D iterative algorithms
%
% This is still slightly experimental.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Add otslm and ott to the path
addpath('../');
addpath('../../ott');

% Describe the incident illumination
incident = ones(512, 512);

NA = 0.8;

% Objective function for optimisation
objective = @(t, a) otslm.iter.objectives.bowman2017cost(t, a, ...
    'roi', @otslm.iter.objectives.roiAll, 'd', 9, 'type', 'amplitude');

%% Generate the target pattern

sz = [64, 64, 64];

target_name = 'twobeams';
switch target_name
  case 'line'
    dimensions = [3, 10, 3]*0.5;
    target = otslm.simple.aperture3d(sz, dimensions, ...
        'shape', 'rect', 'value', [0,1]);
      
  case 'twobeams'
    % Generate a 2-D hologram with two spots
    spacing = 30;
    l1 = otslm.simple.linear(sz(1:2), spacing);
    l2 = otslm.simple.linear(sz(1:2), spacing, 'angle_deg', 90);
    htarget = otslm.tools.combine({l1, l2});
    htarget = otslm.tools.finalize(htarget);
    
    % Calculate 3-D hologram volume
    diameter = sqrt(sum(sz(1:2).^2));
    focal_length = diameter./tan(asin(NA)).*2;
    htarget3d = otslm.tools.hologram2volume(exp(1i*htarget), ...
        'focal_length', focal_length, ...
        'padding', 0, 'zsize', sz(3), 'interpolate', false);
    
    % Visualise hologram to get target
    target = otslm.tools.visualise(htarget3d, ...
          'incident', ones(sz(1:2)), ...
          'padding', ceil(size(htarget3d)/2), 'trim_padding', true, ...
          'method', 'fft3', 'NA', NA);
    target = abs(target).^2;
        
  otherwise
    error('Unknown target name');
end
    

figure();
subplot(1, 3, 1);
imagesc(squeeze(target(end/2+1, :, :)));
xlabel('z');
ylabel('x');
axis image;
subplot(1, 3, 2);
imagesc(squeeze(target(:, end/2+1, :)));
xlabel('z');
ylabel('y');
axis image;
subplot(1, 3, 3);
imagesc(squeeze(target(:, :, round(end/2))));
xlabel('x');
ylabel('y');
axis image;

%% Attempt to generate an optimised beam with BSC method

% Calculate size of pixels [m]
pixel_size = 3.0e-6/dimensions(2);

[pattern, beam, coeffs] = otslm.iter.bsc(size(incident), target, ...
    'incident', incident, 'objective', objective, ...
    'verbose', true, 'basis_size', 20, 'pixel_size', 2e-07, ...
    'radius', 2.0, 'guess', 'rand', 'NA', NA);

figure();
subplot(1, 3, 1);
beam.visualise('axis', 'x');
axis image;
subplot(1, 3, 2);
beam.visualise('axis', 'y');
axis image;
subplot(1, 3, 3);
beam.visualise('axis', 'z');
axis image;

%% Attempt to generate an optimised beam with GS3d method

incident = ones(sz(1:2));

method = otslm.iter.GerchbergSaxton3d(target, ...
  'visdata', {'incident', incident, 'NA', NA, 'zsize', size(target, 3)}, ...
  'invdata', {'NA', NA}, 'objective', objective, 'objective_type', 'min');
pattern = method.run(20, 'show_progress', true);

beam = otslm.tools.hologram2bsc(pattern, ...
  'incident', incident, 'Nmax', 30, 'NA', NA);

figure();
subplot(1, 3, 1);
beam.visualise('axis', 'x');
axis image;
subplot(1, 3, 2);
beam.visualise('axis', 'y');
axis image;
subplot(1, 3, 3);
beam.visualise('axis', 'z');
axis image;

