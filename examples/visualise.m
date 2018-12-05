% Demonstrate different visualisation methods
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Add toolbox to the path
addpath('../');

% Generate pattern with four beams to visualise
sz = [256, 256];
spacing = 80;
pattern1 = otslm.simple.linear(sz, spacing, 'angle_deg', 0);
pattern2 = otslm.simple.linear(sz, spacing, 'angle_deg', 90);
pattern3 = otslm.simple.linear(sz, spacing, 'angle_deg', 180);
pattern4 = otslm.simple.linear(sz, spacing, 'angle_deg', 270);
pattern = otslm.tools.combine({pattern1, pattern2, pattern3, pattern4});
pattern = otslm.tools.finalize(pattern + 0.25);

% Show the pattern
figure();
imagesc(pattern);
caxis([-pi, pi]);

% Open a figure window for the visualisations
hf = figure();

%% Fourier-transoform

z_offset = 5e3;
padding = size(pattern)./2;

im1 = otslm.tools.visualise(pattern, 'method', 'fft', ...
    'padding', padding, 'trim_padding', true);
im2 = otslm.tools.visualise(pattern, 'method', 'fft', ...
    'z', z_offset, 'padding', padding, 'trim_padding', true, ...
    'NA', 0.1);
  
% Zoom into centre of image
o = 35;
im1 = im1(end/2-o:end/2+o, end/2-o:end/2+o);
im2 = im2(end/2-o:end/2+o, end/2-o:end/2+o);

figure(hf);
subplot(2, 2, 1);
imagesc(abs(im1).^2);
axis image;
title('fft2, z=0');
subplot(2, 2, 2);
imagesc(abs(im2).^2);
axis image;
title('fft2, z\neq0');

%% 3-D Fourier transform

xpadding = size(pattern, 1)./2;
zpadding = 100;

im = otslm.tools.visualise(pattern, 'method', 'fft3', ...
    'padding', [xpadding, xpadding, zpadding], ...
    'trim_padding', true, 'NA', 0.6);
  
h3d = figure();
im2 = abs(im).^2;
% im2 = reducevolume(im2, [2, 2, 2]);   % Use this to reduce vis. time
isosurface(im2, 0.01e-6)
axis image;
title('fft3');

%% Optical tweezers toolbox

z_offset = 0.5;

im1 = otslm.tools.visualise(pattern, 'method', 'ott', ...
  'NA', 1.0);
im2 = otslm.tools.visualise(pattern, 'method', 'ott', 'z', z_offset, ...
  'NA', 1.0);

figure(hf);
subplot(2, 2, 3);
imagesc(im1);
axis image;
title('ott, z=0');
subplot(2, 2, 4);
imagesc(im2);
axis image;
title('ott, z\neq0');
