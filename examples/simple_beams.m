% Example of simple beams (figure 2 in otslm paper)
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

sz = [512, 512];      % Size of pattern
o = 50;              % Region of interest size in output
padding = 500;        % Padding for FFT

% incident = [];        % Incident beam (use default in visualize)
incident = otslm.simple.gaussian(sz, 150);  % Incident beam (gaussian)
% incident = ones(sz);  % Incident beam (use uniform illumination)

% Functions used for generating figures
zoom = @(im) im(round(size(im, 1)/2)+(-o:o), round(size(im, 2)/2)+(-o:o));
visualize = @(pattern) zoom(abs(otslm.tools.visualise(pattern, ...
    'method', 'fft', 'padding', padding, 'incident', incident)).^2);

figure();

%% Zero phase pattern (no modification to input beam)

pattern = zeros(sz);
pattern = otslm.tools.finalize(pattern);

subplot(4, 4, 1);
imagesc(pattern);

subplot(4, 4, 2);
imagesc(visualize(pattern));

%% Linear grating (xy displacement)

pattern = otslm.simple.linear(sz, 'spacing', 40, 'angle_deg', 45);
pattern = otslm.tools.finalize(pattern);

subplot(4, 4, 5);
imagesc(pattern);

subplot(4, 4, 6);
imagesc(visualize(pattern));

%% Spherical grating (z displacement)

pattern = otslm.simple.spherical(sz, 200, 'scale', 5, ...
    'background', 'checkerboard');
pattern = otslm.tools.finalize(pattern);

subplot(4, 4, 9);
imagesc(pattern);

subplot(4, 4, 10);
imagesc(visualize(pattern));

%% LG Beam

pattern = otslm.simple.lgmode(sz, 3, 2, 'radius', 50);
pattern = otslm.tools.finalize(pattern);

subplot(4, 4, 13);
imagesc(pattern);

subplot(4, 4, 14);
imagesc(visualize(pattern));

%% HG Beam

pattern = otslm.simple.hgmode(sz, 3, 2, 'scale', 70);
pattern = otslm.tools.finalize(pattern);

subplot(4, 4, 3);
imagesc(pattern);

subplot(4, 4, 4);
imagesc(visualize(pattern));

%% Sinc pattern (line trap)

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

radius = 200;

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

%% Cubic lens (airy beam)

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
