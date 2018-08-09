% Demonstration of effects of phase blur
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

sz = [512, 512];

overdrive = 1.0;   % Overdrive voltages of device
% overdrive = 2.0;   % Overdrive voltages of device

h = figure();
Nr = 4;

%% Fine checkerboard

pattern = otslm.simple.checkerboard(sz, 'spacing', 5);
pattern = otslm.tools.finalize(pattern);

figure(h);
subplot(Nr, 3, 1);
visualise(pattern);
subplot(Nr, 3, 2);
pattern = otslm.tools.phaseblur(pattern.*overdrive);
imagesc(pattern);
  axis image;
  colormap gray;
  set(gca,'YTickLabel', [], 'XTickLabels', []);
subplot(Nr, 3, 3);
visualise(pattern);

%% Course checkerboard

pattern = otslm.simple.checkerboard(sz, 'spacing', 10);
pattern = otslm.tools.finalize(pattern);

figure(h);
subplot(Nr, 3, 4);
visualise(pattern);
subplot(Nr, 3, 5);
pattern = otslm.tools.phaseblur(pattern.*overdrive);
imagesc(pattern);
  axis image;
  colormap gray;
  set(gca,'YTickLabel', [], 'XTickLabels', []);
subplot(Nr, 3, 6);
visualise(pattern);

%% Linear grating

pattern = otslm.simple.linear(sz, 10);
pattern = otslm.tools.finalize(pattern);

figure(h);
subplot(Nr, 3, 7);
visualise(pattern);
subplot(Nr, 3, 8);
pattern = otslm.tools.phaseblur(pattern.*overdrive);
imagesc(pattern);
  axis image;
  colormap gray;
  set(gca,'YTickLabel', [], 'XTickLabels', []);
subplot(Nr, 3, 9);
visualise(pattern);

%% Sinusoid grating

pattern = otslm.simple.sinusoid(sz, 10, 'type', '1d');
pattern = otslm.tools.finalize(pattern);

figure(h);
subplot(Nr, 3, 10);
visualise(pattern);
subplot(Nr, 3, 11);
pattern = otslm.tools.phaseblur(pattern.*overdrive);
imagesc(pattern);
  axis image;
  colormap gray;
  set(gca,'YTickLabel', [], 'XTickLabels', []);
subplot(Nr, 3, 12);
visualise(pattern);

function visualise(pattern)
% Generate visualisation of pattern and display in current figure

  im = otslm.tools.visualise(pattern, 'padding', size(pattern, 1)/4, ...
      'method', 'fft');

  imagesc(abs(im).^2);
  axis image;
  colormap gray;
  set(gca,'YTickLabel', [], 'XTickLabels', []);

end

% function imagesc(im)
% % Function to save images for paper
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
%   imwrite(im, ['phaseblur' num2str(kk) '.png']);
%   kk = kk + 1;
%
% end

