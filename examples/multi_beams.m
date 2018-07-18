% Example to demonstrate combining multiple beams
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Add the otslm toolbox to the path
addpath('../');
import otslm.simple.*;

sz = [512, 512];

%% Generate a couple of simple diffraction grating patterns

pattern1 = linear(sz, 'angle_deg', 90, 'spacing', 20);

pattern2 = linear(sz, 'angle_deg', 90, 'spacing', 40);

pattern3 = linear(sz, 'angle_deg', 45, 'spacing', 20) ...
    + spherical(sz, 100, 'imag_value', 0);

figure(1);
subplot(1, 3, 1);
imagesc(pattern1);
subplot(1, 3, 2);
imagesc(pattern2);
subplot(1, 3, 3);
imagesc(pattern3);

%% Combine patterns: angle(\sum_i exp(1i*2*pi*pattern_i))

combined = otslm.tools.combine({pattern1, pattern2, pattern3}, ...
    'method', 'super');
  
farfield = otslm.tools.visualise(2*pi*combined);
farfield = farfield(floor(size(farfield, 1)/2)+(-50:50), ...
    floor(size(farfield, 2)/2)+(-50:50));

figure(2);
subplot(1, 2, 1);
imagesc(combined);
subplot(1, 2, 2);
imagesc(abs(farfield));
title('super');

%% Combine patterns: angle(\sum_i exp(1i*2*pi*pattern_i + theta_i))

combined = otslm.tools.combine({pattern1, pattern2, pattern3}, ...
    'method', 'rsuper');
  
farfield = otslm.tools.visualise(2*pi*combined);
farfield = farfield(floor(size(farfield, 1)/2)+(-50:50), ...
    floor(size(farfield, 2)/2)+(-50:50));

figure(3);
subplot(1, 2, 1);
imagesc(combined);
subplot(1, 2, 2);
imagesc(abs(farfield));
title('rsuper');

%% Combine patterns: Gerchberg-Saxton algorithm

combined = otslm.tools.combine({pattern1, pattern2, pattern3}, ...
    'method', 'gs');
  
farfield = otslm.tools.visualise(2*pi*combined);
farfield = farfield(floor(size(farfield, 1)/2)+(-50:50), ...
    floor(size(farfield, 2)/2)+(-50:50));

figure(4);
subplot(1, 2, 1);
imagesc(combined);
subplot(1, 2, 2);
imagesc(abs(farfield));
title('GS');


%% Combine patterns: Random sampling

combined = otslm.tools.combine({pattern1, pattern2, pattern3}, ...
    'method', 'dither');
  
farfield = otslm.tools.visualise(2*pi*combined);
farfield = farfield(floor(size(farfield, 1)/2)+(-50:50), ...
    floor(size(farfield, 2)/2)+(-50:50));

figure(5);
subplot(1, 2, 1);
imagesc(combined);
subplot(1, 2, 2);
imagesc(abs(farfield));
title('Dither');
