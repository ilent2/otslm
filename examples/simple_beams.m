% Example of simple beams
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Add toolbox to the path
addpath('../');

sz = [512, 512];      % Size of pattern

% incident = [];        % Incident beam (use default in visualize)
incident = otslm.simple.gaussian(sz, 150);  % Incident beam (gaussian)
% incident = ones(sz);  % Incident beam (use uniform illumination)

% Functions used for generating figures
o = 50;              % Region of interest size in output
padding = 500;        % Padding for FFT
zoom = @(im) im(round(size(im, 1)/2)+(-o:o), round(size(im, 2)/2)+(-o:o));
visualize = @(pattern) zoom(abs(otslm.tools.visualise(pattern, ...
    'method', 'fft', 'padding', padding, 'incident', incident)).^2);

figure();

%% Zero phase pattern (no modification to input beam)
% This is figure 2 (a) from the OTSLM paper.
% The incident beam is not modified

pattern = zeros(sz);
pattern = otslm.tools.finalize(pattern);

subplot(4, 4, 1);
imagesc(pattern);

subplot(4, 4, 2);
imagesc(visualize(pattern));

%% Linear grating (xy displacement)
% This is figure 2 (b) from the OTSLM paper.
% Adds a linear grating to the beam, this produces a transverse
% displacement to the beam in the far-field of the SLM.

pattern = otslm.simple.linear(sz, 40, 'angle_deg', 45);
pattern = otslm.tools.finalize(pattern);

subplot(4, 4, 5);
imagesc(pattern);

subplot(4, 4, 6);
imagesc(visualize(pattern));

%% Spherical grating (z displacement)
% This is figure 2 (c) from the OTSLM paper.
% Adds a spherical phase function to the beam, this produces a axial
% displacement to the beam in the far-field of the SLM.

pattern = otslm.simple.spherical(sz, 200, 'scale', 5, ...
    'background', 'checkerboard');
pattern = otslm.tools.finalize(pattern);

subplot(4, 4, 9);
imagesc(pattern);

subplot(4, 4, 10);
imagesc(visualize(pattern));

%% LG Beam
% This is figure 2 (d) from the OTSLM paper.
% If the incident beam is a Gaussian beam (LG00), this generates a
% LG-like beam with the specified azimuthal and radial mode indices.
%
% This isn't a pure LG beam.  In order to achieve a pure beam we
% also need to modify the amplitude.  See examples/advanced_beams.m.

amode = 3;  % Azimuthal mode
rmode = 2;  % Radial mode

pattern = otslm.simple.lgmode(sz, amode, rmode, 'radius', 50);
pattern = otslm.tools.finalize(pattern);

subplot(4, 4, 13);
imagesc(pattern);

subplot(4, 4, 14);
imagesc(visualize(pattern));

%% HG Beam
% If the incident beam has uniform phase and amplitude, this generates a
% HG-like beam with the specified mode indices.
%
% This isn't a pure HG beam.  In order to achieve a pure beam we
% also need to modify the amplitude.  See examples/advanced_beams.m.

pattern = otslm.simple.hgmode(sz, 3, 2, 'scale', 70);
pattern = otslm.tools.finalize(pattern);

subplot(4, 4, 3);
imagesc(pattern);

subplot(4, 4, 4);
imagesc(visualize(pattern));

%% Sinc pattern (line trap)
% Encodes a 1D sinc amplitude pattern in the height of the phase
% pattern, similar to Roichman and Grier, Opt. Lett. 31, 1675-1677 (2006).

radius = 50;
sinc = otslm.simple.sinc(sz, radius, 'type', '1d');
[pattern, assigned] = otslm.tools.encode1d(sinc, 'scale', 200);

% Apply a checkerboard to unassigned regions
checker = otslm.simple.checkerboard(sz);
pattern(~assigned) = checker(~assigned);

pattern = otslm.tools.finalize(pattern);

subplot(4, 4, 7);
imagesc(pattern);

subplot(4, 4, 8);
imagesc(visualize(pattern));

%% Axicon lens (non-diffracting ring-beam)
% Applies a cone shaped phase pattern to generate a Bessel-like beam.

radius = 50;

pattern = otslm.simple.axicon(sz, -1/radius);

% Remove the corners (recommended for uniform illumination)
% [~, ~, rr] = otslm.simple.grid(sz, 'angle_deg', 0.0);
% assigned = rr < radius;
% checkerboard = otslm.simple.checkerboard(sz);
% pattern(~assigned) = checkerboard(~assigned);

pattern = otslm.tools.finalize(pattern);

subplot(4, 4, 11);
imagesc(pattern);

subplot(4, 4, 12);
imagesc(visualize(pattern));

% We could also look at the near-field of the pattern
% im1 = otslm.tools.visualise(pattern, 'method', 'fft', 'trim_padding', true, 'z', 50000);
% im2 = otslm.tools.visualise(pattern, 'method', 'fft', 'trim_padding', true, 'z', 70000);
% im3 = otslm.tools.visualise(pattern, 'method', 'fft', 'trim_padding', true, 'z', 90000);
% figure();
% subplot(1, 3, 1), imagesc(zoom(abs(im1).^2)), axis image;
% subplot(1, 3, 2), imagesc(zoom(abs(im2).^2)), axis image;
% subplot(1, 3, 3), imagesc(zoom(abs(im3).^2)), axis image;

%% Cubic lens (airy beam)
% Applies a cubic lens function to the beam

pattern = otslm.simple.cubic(sz);
pattern = otslm.tools.finalize(pattern);

subplot(4, 4, 15);
imagesc(pattern);

subplot(4, 4, 16);
imagesc(visualize(pattern));

%% Change properties of all figures

for ii = 1:16
  subplot(4, 4, ii);
  axis('image');
  colormap('gray');
  set(gca,'YTickLabel', [], 'XTickLabels', []);
end

% function imagesc(im)
% 
%   global kk;
% 
%   maxval = max(im(:)) - min(im(:));
%   if maxval == 0.0
%     maxval = 1.0;
%   end
%   
%   im = (im - min(im(:))) ./ maxval;
% 
%   imwrite(im, ['beams' num2str(kk) '.png']);
%   kk = kk + 1;
% 
% end
