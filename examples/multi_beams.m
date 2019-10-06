% Example to demonstrate combining multiple beams
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Add the otslm toolbox to the path
addpath('../');
import otslm.simple.*;

sz = [256, 256];

%% Generate a couple of simple diffraction grating patterns

pattern1 = linear(sz, 20, 'angle_deg', 90);

pattern2 = linear(sz, 40, 'angle_deg', 90);

pattern3 = linear(sz, 20, 'angle_deg', 45) ...
    + spherical(sz, 100, 'background', 0);

figure(1);
subplot(2, 3, 1);
imagesc(otslm.tools.finalize(pattern1));
subplot(2, 3, 2);
imagesc(otslm.tools.finalize(pattern2));
subplot(2, 3, 3);
imagesc(otslm.tools.finalize(pattern3));

subplot(2, 3, 4);
imagesc(vismethod(otslm.tools.finalize(pattern1)));
subplot(2, 3, 5);
imagesc(vismethod(otslm.tools.finalize(pattern2)));
subplot(2, 3, 6);
imagesc(vismethod(otslm.tools.finalize(pattern3)));

%% Combine patterns: angle(\sum_i exp(1i*2*pi*pattern_i))

combined = otslm.tools.combine({pattern1, pattern2, pattern3}, ...
    'method', 'super');
combined = otslm.tools.finalize(combined);
farfield = vismethod(combined);

figure(2);
subplot(1, 2, 1);
imagesc(combined);
subplot(1, 2, 2);
imagesc(abs(farfield));
title('super');

%% Combine patterns: angle(\sum_i exp(1i*2*pi*pattern_i + theta_i))

combined = otslm.tools.combine({pattern1, pattern2, pattern3}, ...
    'method', 'rsuper');
combined = otslm.tools.finalize(combined);
farfield = vismethod(combined);

figure(3);
subplot(1, 2, 1);
imagesc(combined);
subplot(1, 2, 2);
imagesc(abs(farfield));
title('rsuper');

%% Combine patterns: Gerchberg-Saxton algorithm

combined = otslm.tools.combine({pattern1, pattern2, pattern3}, ...
    'method', 'gs');
combined = otslm.tools.finalize(combined);
farfield = vismethod(combined);

figure(4);
subplot(1, 2, 1);
imagesc(combined);
subplot(1, 2, 2);
imagesc(abs(farfield));
title('GS');


%% Combine patterns: Random sampling

combined = otslm.tools.combine({pattern1, pattern2, pattern3}, ...
    'method', 'dither');
combined = otslm.tools.finalize(combined);
farfield = vismethod(combined);

figure(5);
subplot(1, 2, 1);
imagesc(combined);
subplot(1, 2, 2);
imagesc(abs(farfield));
title('Dither');

%% Function for visualisation

function im = vismethod(pattern)
  im = otslm.tools.visualise(pattern, 'method', 'fft', ...
    'trim_padding', true, 'padding', ceil(size(pattern)/2));
  im = abs(im).^2;
  o = 30;
  im = im(end/2-o:end/2+o, end/2-o:end/2+o);
end
  
