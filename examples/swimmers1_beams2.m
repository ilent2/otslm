% Generate figure for swimmers paper

% Add otslm and ott to the path
addpath('../');
addpath('../../ott');

sz = [512, 512];
incident = otslm.simple.gaussian(sz, 200);

% Calculate beam correction amplitude
beamCorrection = 1.0 - incident + 0.8;
beamCorrection(beamCorrection > 1.0) = 1.0;

lineInvLength = 100;
lineAspect = 0.1;
lineAngle = 0;

figure();

%% Gaussian beam

phase = zeros(sz);
visualise(1, phase, 'Gaussian', incident);

%% Flat rectangular trap

phase = otslm.simple.sinc(sz, lineInvLength, 'type', '2dcart', ...
    'angle_deg', 0, 'aspect', lineAspect);
phase = phase .* beamCorrection;
phase = otslm.tools.finalize(zeros(size(phase)), 'amplitude', phase);
visualise(2, phase, 'Flat Rectangle', incident);

farfield = otslm.tools.visualise(phase, 'incident', incident', 'method', 'fft');

%% Rounded rectangular trap

phase = otslm.simple.sinc(sz, lineInvLength, 'type', '2dcart', ...
    'angle_deg', lineAngle, 'aspect', lineAspect);
gaussian = otslm.simple.gaussian(sz, 100, ...
    'type', '1d', 'angle_deg', lineAngle);
phase = phase .* beamCorrection .* gaussian;
phase = otslm.tools.finalize(zeros(size(phase)), 'amplitude', phase);
visualise(3, phase, 'Rounded Rectangle', incident);

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
