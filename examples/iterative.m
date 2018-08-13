% Demonstrate different iterative algorithms
%
% TODO: Some of these algorithms may need a scaling factor for the
% incident or target fields to match the objective function.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Add the toolbox to the path
addpath('../');

sz = [256, 256];
padding = 128;
zm = 50;

incident = otslm.simple.gaussian(sz, 0.5*sz(1));

% Functions used for generating figures
zoom = @(im, o) im(round(size(im, 1)/2)+(-o+1:o), round(size(im, 2)/2)+(-o+1:o));
% zoom = @(im, o) im(1+padding:end-padding, 1+padding:end-padding);
visualize = @(pattern) zoom(abs(otslm.tools.visualise(pattern, ...
    'method', 'fft', 'padding', padding, 'incident', incident)).^2, padding);

im = zeros(sz);
im = insertText(im,[0 -12; 0 12] + sz/2, {'UQ', 'OMG'}, ...
    'FontSize', 18, 'BoxColor', 'black', 'TextColor', 'white', ...
    'BoxOpacity', 0, 'AnchorPoint', 'Center');
im = im(:, :, 1);

hp = figure();
Nf = 6;

subplot(Nf, 2, 2);
imagesc(zoom(im, zm));

roi = @(t, a) otslm.iter.objectives.roiAperture(t, a, ...
  'dimensions', 50);
objective = @(t, a) otslm.iter.objectives.bowman2017cost(t, a, ...
    'roi', roi, 'd', 9);

%% 2-D GS algorithm

pattern = otslm.iter.gs(im, 'incident', incident, 'padding', padding, ...
    'iterations', 500);

figure(hp);

subplot(Nf, 2, 3);
imagesc(pattern);

subplot(Nf, 2, 4);
output = visualize(pattern);
imagesc(zoom(output, zm));

disp(['GS score: ', num2str(objective(im, output))]);

%% Direct search

pattern = otslm.iter.direct_search(im, ...
    'incident', incident, 'levels', 8, 'iterations', prod(sz), ...
    'padding', padding, 'objective', objective);

figure(hp);

subplot(Nf, 2, 5);
imagesc(pattern);

subplot(Nf, 2, 6);
output = visualize(pattern);
imagesc(zoom(output, zm));

disp(['DS score: ', num2str(objective(im, output))]);

%% Simulated annealing

guess = otslm.iter.gs(im, 'incident', incident, 'padding', padding, ...
    'iterations', 10);

pattern = otslm.iter.simulated_annealing(im, ...
    'incident', incident, 'objective', objective, ...
    'initialT', 100, 'maxT', 10000, 'guess', guess, ...
    'iterations', 1000, 'padding', padding);

figure(hp);

subplot(Nf, 2, 7);
imagesc(mod(pattern+pi, 2*pi)-pi);

subplot(Nf, 2, 8);
output = visualize(pattern);
imagesc(zoom(output, zm));

disp(['SA score: ', num2str(objective(im, output))]);

%% Bowman 2017 conjugate gradient method

pattern = otslm.iter.bowman2017(im, 'incident', incident, 'roisize', 100);

figure(hp);

subplot(Nf, 2, 9);
imagesc(pattern);

subplot(Nf, 2, 10);
output = visualize(pattern);
imagesc(zoom(output, zm));
caxis([1e-9, 0.5e-5]);

disp(['Bowman 2017 score: ', num2str(objective(im, output))]);

%% BSC optimisation
% Attempt to optimise beam shape coefficients for tightly focussed fields

addpath('../../ott');

bscim = zoom(im, 30);

[pattern, beam, coeffs] = otslm.iter.bsc(size(incident), bscim, ...
    'incident', incident, 'objective', objective, ...
    'verbose', true, 'basis_size', 40, 'pixel_size', 2e-07, ...
    'radius', 2.0, 'guess', 'rand');

figure(hp);

subplot(Nf, 2, 11);
imagesc(pattern);

subplot(Nf, 2, 12);
output = visualize(pattern);
imagesc(zoom(output, zm));

disp(['BSC1 score: ', num2str(objective(im, output))]);

%% Change properties of all figures

figure(hp);

for ii = 2:2*Nf
  subplot(Nf, 2, ii);
  axis('image');
  colormap('gray');
  if mod(ii, 2) == 0, caxis([1e-9, 1e-5]); end
  set(gca,'YTickLabel', [], 'XTickLabels', []);
end

