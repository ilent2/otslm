% Example of more advanced beams (figure 3 in otslm paper)

% Add toolbox to the path
addpath('../');

sz = [512, 512];      % Size of pattern
% o = 100;               % Region of interest size in output
padding = 500;        % Padding for FFT

% incident = [];        % Incident beam (use default in visualize)
incident = otslm.simple.gaussian(sz, 100);  % Incident beam (gaussian)
% incident = ones(sz);  % Incident beam (use uniform illumination)

beamCorrection = 1.0 - incident*1.0;

% Functions used for generating figures
zoom = @(im, o) im(round(size(im, 1)/2)+(-o:o), round(size(im, 2)/2)+(-o:o));
visualize = @(pattern, o) zoom(abs(otslm.tools.visualise(pattern, ...
    'method', 'fft', 'padding', padding, 'incident', incident)).^2, o);

figure();

%% Adding beam phase to shift beams

pattern = otslm.simple.lgmode(sz, 3, 2, 'radius', 50);
pattern = pattern + otslm.simple.linear(sz, 'spacing', 30);
pattern = otslm.tools.finalize(pattern);

subplot(4, 4, 1);
imagesc(pattern);

subplot(4, 4, 2);
imagesc(visualize(pattern, 100));

%% Mixing beams with superposition

pattern1 = otslm.simple.linear(sz, 'spacing', 30, 'angle_deg', 90);
pattern2 = otslm.simple.linear(sz, 'spacing', 30, 'angle_deg', 0);

pattern = otslm.tools.combine({pattern1, pattern2}, ...
    'method', 'super');

pattern = otslm.tools.finalize(pattern);

subplot(4, 4, 5);
imagesc(pattern);

subplot(4, 4, 6);
imagesc(visualize(pattern, 100));

%% Gerchberg-Saxton demonstration

%% HG beam with amplitude correction for Gaussian illumination

pattern = otslm.simple.hgmode(sz, 3, 2, 'scale', 50);
pattern = otslm.tools.finalize(pattern, 'amplitude', beamCorrection);

subplot(4, 4, 13);
imagesc(pattern);

subplot(4, 4, 14);
imagesc(visualize(pattern, 20));

%% Counter rotating LG beams

% % lgpattern1 = otslm.simple.lgmode(sz, 5, 3, 'centre', [ 200, 200 ]);
% % lgpattern2 = otslm.simple.lgmode(sz, -2, 1, 'centre', [ 370, 370 ]);
% 
% % This is pretty, but not what we want?
% lgpattern1 = otslm.simple.lgmode(sz, 10, 1);
% lgpattern2 = otslm.simple.lgmode(sz, -2, 1);
% 
% % Hmm, this doesn't produce the espected output yet...
% pattern = otslm.tools.combine({lgpattern1, lgpattern2}, ...
%     'method', 'rsuper');
%   
% % shift = otslm.simple.linear(sz, 'spacing', 50);
% % pattern = pattern + shift;
% 
% pattern = otslm.tools.finalize(pattern);
% 
% subplot(4, 4, 3);
% imagesc(pattern);
% 
% subplot(4, 4, 4);
% imagesc(visualize(pattern, 30));

%% Array of LG beams

lgpattern = otslm.simple.lgmode(sz, 5, 0);
grating = otslm.simple.sinusoid(sz, 50, 'type', '2dcart');

pattern = lgpattern + grating;
pattern = otslm.tools.finalize(pattern, 'amplitude', beamCorrection);

subplot(4, 4, 7);
imagesc(pattern);

subplot(4, 4, 8);
imagesc(visualize(pattern, 100));

%% Binary amplitude LG beam

dmdsz = [512, 1024];
aspect = 2;

% Calculate phase and amplitude for LG beam
[phase, amplitude] = otslm.simple.lgmode(dmdsz, 3, 0, ...
    'aspect', aspect, 'radius', 100);

% Shift the pattern away from the zero-th order (rotate away from artifacts)
phase = phase + otslm.simple.linear(dmdsz, 'spacing', 40, ...
    'angle_deg', 62, 'aspect', aspect);
  
% Finalize the pattern: encoding amplitude and phase into amplitude pattern
pattern = otslm.tools.finalize(phase, 'amplitude', amplitude, ...
    'device', 'dmd', 'colormap', 'gray', 'rpack', 'none');

% Dither the resulting pattern
%   tools.finalize could do this, be we want more control
%   we need to do rpack after dithering, so we call finalize again
pattern = otslm.tools.dither(pattern, 0.5, 'method', 'random');
patternVis = otslm.tools.finalize(pattern, ...
    'colormap', 'gray', 'rpack', '45deg', 'modulo', 'none');

dmdincident = ones(size(patternVis));

subplot(4, 4, 11);
imagesc(pattern);

subplot(4, 4, 12);
visOutput = abs(otslm.tools.visualise([], 'amplitude', patternVis, ...
    'method', 'fft', 'padding', padding, 'incident', dmdincident)).^2;
visOutput = visOutput(ceil(size(visOutput, 1)/2)-50+(-40:40), ...
    ceil(size(visOutput, 2)/2 +(-40:40)));
imagesc(visOutput);

%% Selecting regions of interest

loc1 = [ 170, 150 ];
radius1 = 75;
pattern1 = otslm.simple.lgmode(sz, 3, 0, 'centre', loc1);
pattern1 = pattern1 + otslm.simple.linear(sz, 'spacing', 20);
pattern1 = otslm.tools.finalize(pattern1, 'amplitude', beamCorrection, ...
    'colormap', 'gray');

loc2 = [ 320, 170 ];
radius2 = 30;
pattern2 = zeros(sz);

loc3 = [ 270, 300 ];
radius3 = 50;
pattern3 = otslm.simple.linear(sz, 'spacing', -20, 'angle_deg', 45);
pattern3 = otslm.tools.finalize(pattern3, 'amplitude', 0.2, ...
    'colormap', 'gray');

background = otslm.simple.checkerboard(sz);

pattern = otslm.tools.mask_regions(background, ...
    {pattern1, pattern2, pattern3}, {loc1, loc2, loc3}, ...
    {radius1, radius2, radius3}, 'type', 'circle');
  
pattern = otslm.tools.finalize(pattern);

subplot(4, 4, 15);
imagesc(pattern);

subplot(4, 4, 16);
imagesc(visualize(pattern, 110));

%% Change properties of all figures

for ii = 1:16
  subplot(4, 4, ii);
  axis('image');
  colormap('gray');
  set(gca,'YTickLabel', [], 'XTickLabels', []);
end

% function imagesc(im)
% 
%   global kk;
% 
%   maxval = max(im(:)) - min(im(:));
%   if maxval == 0.0
%     maxval = 1.0;
%   end
%   
%   im = (im - min(im(:))) ./ maxval;
% 
%   imwrite(im, ['beams' num2str(kk) '.png']);
%   kk = kk + 1;
% 
% end

