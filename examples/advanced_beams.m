% Example of more advanced beams (figure 3 in otslm paper)

sz = [512, 512];      % Size of pattern
% o = 100;               % Region of interest size in output
padding = 500;        % Padding for FFT

% incident = [];        % Incident beam (use default in visualize)
incident = otslm.simple.gaussian(sz, 100);  % Incident beam (gaussian)
% incident = ones(sz);  % Incident beam (use uniform illumination)

beamCorrection = 1.0 - incident;

% Functions used for generating figures
zoom = @(im, o) im(round(size(im, 1)/2)+(-o:o), round(size(im, 2)/2)+(-o:o));
visualize = @(pattern, o) zoom(abs(otslm.tools.visualise(pattern, ...
    'method', 'fft', 'padding', padding, 'incident', incident)).^2, o);

figure();

%% Adding beam phase to shift beams

%% Mixing beams with superposition

%% Gerchberg-Saxton demonstration

%% HG beam with amplitude correction for Gaussian illumination

pattern = otslm.simple.hgmode(sz, 3, 2, 'scale', 50);
pattern = otslm.tools.finalize(pattern, 'amplitude', beamCorrection);

subplot(4, 4, 3);
imagesc(pattern);

subplot(4, 4, 4);
imagesc(visualize(pattern, 20));

%% Counter rotating LG beams

%% Array of LG beams

lgpattern = otslm.simple.lgmode(sz, 5, 0);
grating = otslm.simple.sinusoid(sz, 50, 'type', '2dcart');

pattern = lgpattern + grating;
pattern = otslm.tools.finalize(pattern, 'amplitude', beamCorrection);

subplot(4, 4, 1);
imagesc(pattern);

subplot(4, 4, 2);
imagesc(visualize(pattern, 100));

%% Binary amplitude LG beam

%% Selecting regions of interest

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

