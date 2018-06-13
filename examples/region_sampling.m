% Demonstrating of otslm.tools.sample_region function

sz = [512, 512];
locations = {[ 100, 100 ], [ 300, 250 ], [ 200, 100 ] };
detectors = {[ 0, 10 ], [ 20, 0 ], [ 10, 5 ]};
radii = [ 10, 20, 15 ]*2;

% amplitude_opts = {'step'};
% amplitude_opts = {'gaussian_dither'};
% amplitude_opts = {'gaussian_noise'};
amplitude_opts = {'gaussian_scale', 'mix', 'sadd'};

% Generate pattern
pattern = otslm.tools.sample_region(sz, locations, detectors, ...
    'radii', radii, 'background', 'checkerboard', 'amplitude', amplitude_opts);

% Show pattern
figure(1);
imagesc(pattern);
title('phase pattern');

% Show far-field amplitude
figure(2);
imagesc(abs(otslm.tools.visualise(pattern*2*pi)));
title('Far-field amplitude');

