% Attempt to generate a line trap in 3-D using BSC iterative optimisation
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Add otslm and ott to the path
addpath('../');
addpath('../../ott');

% Describe the incident illumination
incident = ones(512, 512);

%% Generate the target pattern
sz = [60, 30, 30];
dimensions = [5, 20, 5];
target = otslm.simple.aperture3d(sz, dimensions, ...
    'type', 'rect', 'values', [0,1]);

figure();
subplot(1, 3, 1);
imagesc(squeeze(target(end/2, :, :)));
axis image;
subplot(1, 3, 2);
imagesc(squeeze(target(:, end/2, :)));
axis image;
subplot(1, 3, 3);
imagesc(squeeze(target(:, :, end/2)));
axis image;

%% Attempt to generate an optimised beam

% Calculate size of pixels [m]
pixel_size = 3.0e-6/dimensions(2);

% Objective function for optimisation
objective = @(t, a) otslm.iter.objectives.bowman2017cost(t, a, ...
    'roi', @otslm.iter.objectives.roiAll, 'd', 9);

[pattern, beam, coeffs] = otslm.iter.bsc(size(incident), target, ...
    'incident', incident, 'objective', objective, ...
    'verbose', true, 'basis_size', 20, 'pixel_size', 2e-07, ...
    'radius', 2.0, 'guess', 'rand');

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

