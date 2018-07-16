% Beams for swimmers 1 paper

% Add otslm and ott to path
addpath('../');
addpath('../../ott');

sz = [512, 512];
sigma = 200;

incident = otslm.simple.gaussian(sz, sigma);

figure();

%% Simulate gaussian beam with toolbox

pattern = zeros(sz);
farfield = otslm.tools.visualise(pattern, 'incident', incident, ...
    'method', 'ott');
  
subplot(2, 3, 1);
imagesc(pattern);

subplot(2, 3, 4);
imagesc(abs(farfield).^2);

%% Simulate first type of line trap

sinc = otslm.simple.sinc(sz, 0.05, 'type', '1d', 'angle_deg', 0.0);
[~, yy] = otslm.simple.grid(sz, 'angle_deg', 0.0);
phi = (sinc >= 0)*0.5;
assigned = (abs(yy) < abs(sinc*100.0));
pattern = phi .* assigned;

checkerboard = otslm.simple.checkerboard(sz);
pattern(~assigned) = checkerboard(~assigned);

pattern = otslm.tools.finalize(pattern);

farfield = otslm.tools.visualise(pattern, 'incident', incident, ...
    'method', 'ott');

subplot(2, 3, 2);
imagesc(pattern);

subplot(2, 3, 5);
imagesc(abs(farfield).^2);

%% Simulate second type of line trap

% TODO