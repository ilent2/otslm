% Generate a ring beam using GS for E Coli trapping, compare to LG

sz = [512, 512];
incident = otslm.simple.gaussian(sz, 200);  % Incident beam (gaussian)

figure();

%% Generate LG beam

pattern = otslm.simple.lgmode(sz, 5, 0);
pattern = otslm.tools.finalize(pattern);

visualise(1, pattern, 'LG', incident);

%% Generate ring using GS

r1 = 5;
r2 = 9;

apperture1 = otslm.simple.aperture(sz, r1);
apperture2 = otslm.simple.aperture(sz, r2);

amplitude = 1.0*apperture2 - 1.0*apperture1;

pattern = otslm.iter.gs(amplitude, 'incident', incident, 'padding', 500);

pattern = imresize(pattern, sz);

visualise(2, pattern, 'GS', incident);

%% Generate ring using GS with gaussian blur

r1 = 4;
r2 = 9;

apperture1 = otslm.simple.aperture(sz, r1);
apperture2 = otslm.simple.aperture(sz, r2);

amplitude = 1.0*apperture2 - 1.0*apperture1;

% Apply gaussian blur to the image
sigma = 2;
amplitude = imgaussfilt(amplitude, sigma);
amplitude = amplitude ./ max(abs(amplitude(:)));

pattern = otslm.iter.gs(amplitude, 'incident', incident, 'padding', 500);

visualise(3, pattern, 'GSB', incident);

%% Function to generate visualisations

function visualise(row, phase, name, incident)

% Calculate intensity transver to beam axis
[intensityZ, beam] = otslm.tools.visualise(phase, 'incident', incident, ...
    'method', 'ott', 'axis', 'z');

% Generate slice through beam
slice = intensityZ(ceil(size(intensityZ, 1)/2), :);

% Calculate intensity along beam axis
intensityX = otslm.tools.visualise(phase, 'incident', incident, ...
    'method', 'ott', 'methoddata', beam, 'axis', 'x');

intensityY = otslm.tools.visualise(phase, 'incident', incident, ...
    'method', 'ott', 'methoddata', beam, 'axis', 'y');

subplot(3, 4, 1 + (row-1)*4);
plot(1:length(slice), slice);
xlabel('X Position');
ylabel(['Intensity: ', name]);

subplot(3, 4, 2 + (row-1)*4);
imagesc(intensityX);
axis('image');
colormap('gray');
set(gca,'YTickLabel', [], 'XTickLabels', []);

subplot(3, 4, 3 + (row-1)*4);
imagesc(intensityY);
axis('image');
colormap('gray');
set(gca,'YTickLabel', [], 'XTickLabels', []);

subplot(3, 4, 4 + (row-1)*4);
imagesc(intensityZ);
axis('image');
colormap('gray');
set(gca,'YTickLabel', [], 'XTickLabels', []);

end