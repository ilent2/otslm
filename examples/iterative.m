% Demonstrate different iterative algorithms

% Add the toolbox to the path
addpath('../');

sz = [256, 256];
padding = 100;

incident = otslm.simple.gaussian(sz, 0.5*sz(1));

% Functions used for generating figures
% zoom = @(im, o) im(round(size(im, 1)/2)+(-o:o), round(size(im, 2)/2)+(-o:o));
zoom = @(im, o) im(1+padding:end-padding, 1+padding:end-padding);
visualize = @(pattern, o) zoom(abs(otslm.tools.visualise(pattern, ...
    'method', 'fft', 'padding', padding, 'incident', incident)).^2, o);

im = zeros(sz);
im = insertText(im,[7 0; 0 25] + [ 115, 112 ], {'UQ', 'OMG'}, ...
    'FontSize', 18, 'BoxColor', 'black', 'TextColor', 'white', 'BoxOpacity', 0);
im = im(:, :, 1);

hp = figure();
Nf = 4;

objective = @(t, a) otslm.iter.objectives.bowman2017cost(t, a, ...
    'roi', @otslm.iter.objectives.roiAperture, 'd', 11);

%% 2-D GS algorithm

pattern = otslm.iter.gs(im, 'incident', incident);

figure(hp);

subplot(Nf, 2, 1);
imagesc(pattern);

subplot(Nf, 2, 2);
imagesc(visualize(pattern, 100));

%% Direct search

pattern = otslm.iter.direct_search(im, ...
    'incident', incident, 'levels', 8, 'iterations', prod(sz));

figure(hp);

subplot(Nf, 2, 3);
imagesc(pattern);

subplot(Nf, 2, 4);
imagesc(visualize(pattern, 100));

%% Simulated annealing

pattern = otslm.iter.simulated_annealing(im, ...
    'incident', incident, 'objective', objective, 'guess', pattern, ...
    'initialT', 50, 'iterations', 10000);

figure(hp);

subplot(Nf, 2, 5);
imagesc(pattern);

subplot(Nf, 2, 6);
imagesc(visualize(pattern, 100));

%% Bowman 2017 conjugate gradient method

pattern = otslm.iter.bowman2017(im, 'incident', incident, 'roisize', 100);

figure(hp);

subplot(Nf, 2, 7);
imagesc(pattern);

% TODO: There is a problem with scaling
subplot(Nf, 2, 8);
farfield = visualize(pattern, 100);
imagesc(farfield(105:105+71, 80:80+120));

%% Change properties of all figures

figure(hp);

for ii = 1:2*Nf
  subplot(Nf, 2, ii);
  axis('image');
  colormap('gray');
  set(gca,'YTickLabel', [], 'XTickLabels', []);
end

