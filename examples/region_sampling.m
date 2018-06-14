% Demonstrating of otslm.tools.sample_region function

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

% Show pattern
figure(1);
imagesc(pattern);
title('Phase pattern');

% Calculate the farfield
farfield = otslm.tools.visualise(pattern*2*pi);

% Mask the zero-th order
% farfield = farfield .* ~otslm.simple.aperture(size(farfield), 10);

% Show far-field amplitude
figure(2);
imagesc(abs(farfield(100:end-100, 100:end-100)));
title('Far-field amplitude');

