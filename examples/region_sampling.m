% Demonstrating of otslm.tools.sample_region function
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Add toolbox to the path
addpath('../');

sz = [512, 512];
locations = {[ 180, 300 ], [ 300, 300 ], [ 200, 200 ] };
detectors = {[ 0, 10 ], [ 20, 0 ], [ 10, 5 ]};
radii = [ 10, 20, 15 ]*2;

% amplitude_opts = {'step'};
amplitude_opts = {'gaussian_dither'};
% amplitude_opts = {'gaussian_noise'};
% amplitude_opts = {'gaussian_scale', 'mix', 'sadd'};

% Generate pattern
pattern = otslm.tools.sample_region(sz, locations, detectors, ...
    'radii', radii, 'background', 'random', 'amplitude', amplitude_opts);
pattern = otslm.tools.finalize(pattern);

% Show pattern
figure(1);
imagesc(pattern);
title('Phase pattern');

% Calculate the farfield
farfield = otslm.tools.visualise(pattern, 'method', 'fft', ...
  'trim_padding', true);

% Mask the zero-th order
% farfield = farfield .* ~otslm.simple.aperture(size(farfield), 10);

% Show far-field amplitude
figure(2);
imagesc(abs(farfield).^2);
title('Far-field amplitude');

