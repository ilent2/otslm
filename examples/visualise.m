% Demonstrate different visualisation methods
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Add toolbox to the path
addpath('../');

% Generate pattern to simulate
sz = [512, 512];
pattern = otslm.simple.linear(sz, 10, 'angle_deg', 45);
pattern = otslm.tools.finalize(pattern);

figure();

%% Fourier-transoform

z_offset = 100;
padding = 500;

im1 = otslm.tools.visualise(pattern, 'method', 'fft', ...
    'padding', padding);
im2 = otslm.tools.visualise(pattern, 'method', 'fft', ...
    'z', z_offset, 'padding', padding);

im1 = im1(630:670, 845:885);
im2 = im2(630:670, 845:885);

subplot(3, 2, 1);
imagesc(abs(im1));
axis image;
subplot(3, 2, 2);
imagesc(abs(im2));
axis image;

%% Rayleigh-Sommerfeld integral with lens

z_offset = 100;

tic
imtest = otslm.tools.visualise(pattern, 'method', 'rs', 'z', 1000);
runTime = toc();

% im1 = otslm.tools.visualise(pattern, 'method', 'rslens', ...
%     'focallength', 1000, 'z', 1000);
% im2 = otslm.tools.visualise(pattern, 'method', 'rslens', 'z', z_offset);

subplot(3, 2, 3);
imagesc(abs(im1));
axis image;
subplot(3, 2, 4);
% imagesc(abs(im2));
axis image;

%% Optical tweezers toolbox

% im1 = otslm.tools.visualise(pattern, 'method', 'ott');
% im2 = otslm.tools.visualise(pattern, 'method', 'ott', 'z', z_offset);
% 
% subplot(3, 2, 5);
% imagesc(abs(im1));
% axis image;
% subplot(3, 2, 6);
% imagesc(abs(im2));
% axis image;
