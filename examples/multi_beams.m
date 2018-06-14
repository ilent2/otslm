
% Add the otslm toolbox to the path
addpath('../');
import otslm.simple.*;

sz = [512, 512];

%% Generate a couple of simple diffraction grating patterns

pattern1 = linear(sz, 'angle_deg', 45, 'spacing', 10);

pattern2 = linear(sz, 'gradient', [0.01, 0]);

pattern3 = linear(sz) + spherical(sz, 100, 'imag_value', 0);

figure(1);
subplot(1, 3, 1);
imagesc(pattern1);
subplot(1, 3, 2);
imagesc(pattern2);
subplot(1, 3, 3);
imagesc(pattern3);

%% Combine patterns

combined = otslm.tools.combine({pattern1, pattern2, pattern3}, ...
    'method', 'expangle');

figure(2);
imagesc(combined);

%% Visualise far field

farfield = otslm.tools.visualise(combined*2*pi);

figure(3);
subplot(1, 2, 1);
imagesc(abs(farfield));
subplot(1, 2, 2);
imagesc(angle(farfield));
