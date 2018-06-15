% Attempt to reproduce the beam from Roichman and Grier (2006).

% Add toolbox to path
addpath('../');

sz = [512, 512];              % Pattern size
L = 0.05;                     % Length of the line
theta = 0.0;                  % Rotation of pattern
scale = 100.0;                % Scale for intensity of line
background = 'checkerboard';  % Background values to use
max_width = sz(1);            % Max pattern width (spatial filtering)
noise_factor = 0.0;           % Noise to blur out the pattern

sinc = otslm.simple.sinc(sz, L, 'type', '1d', 'angle_deg', theta);
[xx, yy, rr] = otslm.simple.grid(sz, 'angle_deg', theta);

phi = (sinc >= 0)*0.5;
assigned = (abs(yy) < abs(sinc*scale));
pattern = phi .* assigned;

%% Repeat the process if we are broadening the line (doesn't work)

% L2 = 0.02;                    % Width of the line
% scale2 = 0.0;                 % Scale for second sinc
% 
% sinc2 = otslm.simple.sinc(sz, L2, 'type', '1d', 'angle_deg', theta+90);
% 
% phi2 = (sinc2 >= 0)*0.5;
% assigned2 = (abs(xx) < abs(sinc2*scale2));
% pattern = pattern + phi2 .* assigned .* assigned2;

% Only include the overlap of the two regions
% assigned = assigned & assigned2;

%% Apply an aperture (broaden the pattern, remove higher frequencies)
assigned = assigned & rr < max_width/2;

%% Add noise to blur out the pattern
pattern(assigned) = pattern(assigned) ...
    + rand(size(pattern(assigned)))*noise_factor;

%% Add a linear diffraction grating to move the pattern
shift = otslm.simple.linear(sz, 'spacing', 25, 'angle_deg', 45);
pattern(assigned) = shift(assigned)+pattern(assigned);

%% Remove the excess light

switch background
  case 'linear'

    % Add a linear diffraction grating to unassigned region
    linear = otslm.simple.linear(sz, 'spacing', 15, 'angle_deg', 45);
    pattern(~assigned) = linear(~assigned);
    
  case 'random'

    % Apply random phase the the non-assigned region
    pattern(~assigned) = rand(size(pattern(~assigned)));
    
  case 'checkerboard'

    % Apply a checkerboard to the unassigned regions
    checker = otslm.simple.checkerboard(sz);
    pattern(~assigned) = checker(~assigned);
   
  otherwise
    error('Unknown background type specified');
    
end

%% Finalize the pattern (makes it in the range -pi to pi)
pattern = otslm.tools.finalize(pattern);

%% Visualise the pattern

figure(1);
subplot(1, 2, 1);
imagesc(assigned);
subplot(1, 2, 2);
imagesc(pattern);

%% Generate far field image and crop to roi
farfield = otslm.tools.visualise(pattern, 'method', 'fft');
farfield = farfield(floor(size(farfield, 1)/2)+(-50:50), ...
    floor(size(farfield, 2)/2)+(-50:50));

figure(2);
imagesc(abs(farfield));

