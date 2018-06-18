% Demonstrate the current DMD functionality of the toolbox
%  This is for a DMD with tiling that gives it a 1:2 aspect ratio

dmdsz = [512, 1024];
aspect = 2;

%% Generate a simple circle aperture, display it and its farfield

% Generate the pattern
pattern = otslm.simple.aperture(dmdsz, 200, ...
    'aspect', aspect, 'type', 'circle');

% Transform the pattern to dmd coordinates
pattern = otslm.tools.finalize(pattern, 'device', 'dmd');

% Calculate the output for the simulated pattern
output = otslm.tools.visualise([], 'amplitude', pattern);

% Zoom to region of interest
pad = 550;
output = output(pad:end-pad, pad:end-pad);

figure(1);
subplot(1, 2, 1);
imagesc(pattern);
title('DMD amplitude pattern');
subplot(1, 2, 2);
imagesc(abs(output));
title('Farfield for DMD circular aperture');

%% Generate a LG beam hologram with dithered phase control
% Attempts to reproduce the figure in
% V. Lerner, D. Shwa, Y. Drori, and N. Katz, Opt. Lett. 37, 4826-4828 (2012)

amode = 3;
rmode = 3;

% Calculate phase and amplitude for LG beam
[phase, amplitude] = otslm.simple.lgmode(dmdsz, amode, rmode, ...
    'aspect', aspect, 'radius', 50, 'p0', 0.5);

% Shift the pattern away from the zero-th order (rotate away from artifacts)
phase = phase + otslm.simple.linear(dmdsz, 'spacing', 30, ...
    'angle_deg', 45, 'aspect', aspect);

% Finalize the pattern: encoding amplitude and phase into amplitude pattern
pattern = otslm.tools.finalize(phase, 'amplitude', amplitude, ...
    'device', 'dmd', 'colormap', 'gray', 'rpack', 'none');

% Dither the resulting pattern
%   tools.finalize could do this, be we want more control
%   we need to do rpack after dithering, so we call finalize again
pattern = otslm.tools.dither(pattern, 0.5, 'method', 'random');
pattern = otslm.tools.finalize(pattern, ...
    'colormap', 'gray', 'rpack', '45deg', 'modulo', 'none');

% Calculate the output for the simulated pattern
output = otslm.tools.visualise([], 'amplitude', pattern);

% Zoom to a single diffracted region
output = output(670+(-20:20), 613+(-20:20));

figure(2);
subplot(1, 3, 1);
imagesc(pattern);
title('DMD LG amplitude pattern');
subplot(1, 3, 2);
imagesc(abs(output));
title('Farfield amplitude of LG pattern');
subplot(1, 3, 3);
imagesc(angle(output));
title('Farfield phase of LG pattern');

