% Simulation of different types of line traps
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Add toolbox to path
addpath('../');

radius = 50;          % Inverse length of the line trap (sinc radius)
theta = 45.0;         % Rotation of pattern (degrees)

sz = [512, 512];      % Size of pattern
o = 50;               % Region of interest size in output
padding = 500;        % Padding for FFT

incident = [];        % Incident beam (use default in visualize)
% incident = ones(sz);  % Incident beam (use uniform illumination)

% Functions used for generating figures
zoom = @(im) im(round(size(im, 1)/2)+(-o:o), round(size(im, 2)/2)+(-o:o));
visualize = @(pattern) zoom(abs(otslm.tools.visualise(pattern, ...
    'method', 'fft', 'padding', padding, 'incident', incident)).^2);
  
figure();

%% Roichman and Grier (2006) using 1-D line trap with amplitude encoded in 2d

sinc = otslm.simple.sinc(sz, radius, 'type', '1d', 'angle_deg', theta);
[pattern, assigned] = otslm.tools.encode1d(sinc, ...
    'angle_deg', theta, 'scale', 200);
  
% Apply a checkerboard to unassigned regions
checker = otslm.simple.checkerboard(sz);
pattern(~assigned) = checker(~assigned);

pattern = otslm.tools.finalize(pattern);

subplot(3, 2, 1);
imagesc(pattern);

subplot(3, 2, 2);
imagesc(visualize(pattern));

%% 1-D line trap everywhere with amplitude encoded in phase

pattern = otslm.simple.sinc(sz, radius, 'type', '1d', 'angle_deg', theta);
pattern = otslm.tools.finalize(zeros(size(pattern)), 'amplitude', pattern);

subplot(3, 2, 3);
imagesc(pattern);

subplot(3, 2, 4);
imagesc(visualize(pattern));

%% 2-D line trap (rectangle, two sincs)

pattern = otslm.simple.sinc(sz, radius, 'type', '2dcart', ...
    'angle_deg', theta, 'aspect', 0.3);
pattern = otslm.tools.finalize(zeros(size(pattern)), 'amplitude', pattern);

subplot(3, 2, 5);
imagesc(pattern);

subplot(3, 2, 6);
imagesc(visualize(pattern));

%% Change properties of all figures

for ii = 1:6
  subplot(3, 2, ii);
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
