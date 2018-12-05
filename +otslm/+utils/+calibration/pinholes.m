function lt = pinholes(slm, cam, varargin)
% PINHOLES generates virtual pinholes with different phase
%
% Similar to step but looks at interference of two regions on
% different parts of the device allowing per-pixel or per-region
% calibration.
%
% lt = pinholes(slm, cam, ...) calibrates using the pinholes method.
%
% Optional named arguments:
%     slice_offset    num     slice distance from image centre
%     slice_width     num     width of the slice to average over
%     slice_angle     num     angle for the slice (deg)
%     freq_index      idx     index for frequency sample
%     delay           num     delay after displaying slm image
%     stride          num     number of linear indexes to step
%     basevalue       num     value to use for the first region
%     radius          num     radius of pinholes (pixels)
%
%     verbose         bool    display progress in console
%     show_progress   bool    show progress figure
%     show_camera     bool    show what the camera sees
%     show_spectrum   bool    show the 1-D Fourier spectrum of the images
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Parse method arguments
p = inputParser;
p.addParameter('slice_offset', 0);
p.addParameter('slice_width', 1);
p.addParameter('slice_angle', 0);
p.addParameter('freq_index', 1);
p.addParameter('delay', []);
p.addParameter('stride', 1);
p.addParameter('verbose', true);
p.addParameter('show_progress', false);
p.addParameter('show_camera', false);
p.addParameter('show_spectrum', false);
p.addParameter('basevalue', 1);
p.addParameter('radius', min(slm.size)./5);
p.parse(varargin{:});

assert(p.Results.stride >= 1 ...
  && p.Results.stride == round(p.Results.stride), ...
  'Stride must be positive non-zero integer');
assert(p.Results.slice_width > 0, ...
  'Slice width must be positive');
assert(p.Results.basevalue >= 1 ...
  && p.Results.basevalue == round(p.Results.basevalue), ...
  'basevalue must be positive non-zero integer');

% Design a pattern that minimises intensity in target
% This adds noise to the output, but can still produce reasonable results
% TODO: Allow the user to supply a base pattern or use checkerboard
% TODO: Average over multiple background patterns
% TODO: Optimisation to minimise power in zeroth order
% TODO: This method has overlap with step, reuse code?
basepattern = randi(slm.valueRangeNumel(), slm.size);

% Generate mask for pinhole regions
r = min(slm.size)./5;
o = slm.size(2)./4;
c1 = [ceil(slm.size(2)/2)-o, ceil(slm.size(1)/2)];
c2 = [ceil(slm.size(2)/2)+o, ceil(slm.size(1)/2)];
mask_pinhole1 = otslm.simple.aperture(slm.size, r, 'centre', c1);
mask_pinhole2 = otslm.simple.aperture(slm.size, r, 'centre', c2);

% Generate full value table
valueTable = slm.linearValueRange('structured', true);

% Create a figure to track the progress
if p.Results.show_progress
  hf = figure();
  h = axes(hf);

  % Create plots for each sample run
  plt = plot(h, 0, 0);

  xlabel(h, 'linear pixel range');
  ylabel(h, 'Phase');
  title(h, 'Step calibration progress');

  % Create a stop button
  btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Stop',...
      'Position', [20 20 50 20]);
  btn.Enable = 'Inactive';
  btn.UserData = true;
  btn.ButtonDownFcn = @(src, event) set(btn, 'UserData', false);
  drawnow;

  figure_active = @() ishandle(hf) && btn.UserData;
else
  figure_active = @() true;
end

% Setup figure for show_camera
if p.Results.show_camera
  hcf = figure();
  hc = axes(hcf);
end

% Setup figure for show_spectrum
if p.Results.show_spectrum
  hsf = figure();
  hs = axes(hsf);
end

% Setup variables for interpolation of slice
im = cam.viewTarget();
imwidth = size(im, 2);
imheight = size(im, 1);
theta = pi/180 * p.Results.slice_angle;
offset = p.Results.slice_offset;
swidth = p.Results.slice_width;
len = sqrt(imwidth.^2 + imheight.^2);
[xx0, yy0] = meshgrid(1:imwidth, 1:imheight);
[xx, yy] = meshgrid(-len/2:len/2, (0.5:(swidth-0.5)) + offset);
xxR = xx .* cos(theta) + imwidth/2 - yy .* sin(theta);
yyR = xx .* sin(theta) + imheight/2 + yy .* cos(theta);

% Measure phase of each value
idx = 1:p.Results.stride:size(valueTable, 2);
phase = zeros(size(valueTable, 2), 1);
for ii = 1:p.Results.stride:size(valueTable, 2)

  % Display output to terminal
  if p.Results.verbose
    disp(['Pinholes calibration: ', num2str(ii), ...
        '/', num2str(size(valueTable, 2))]);
  end
  
  % Generate raw pattern
  ipattern = basepattern;
  ipattern(mask_pinhole1) = p.Results.basevalue;
  ipattern(mask_pinhole2) = ii;

  % Display on slm
  slm.showIndexed(ipattern);

  % Allow for a finite device response rate
  if ~isempty(p.Results.delay)
    pause(p.Results.delay);
  end

  % Acquire image
  im = cam.viewTarget();

  % Show the camera image
  if p.Results.show_camera
    imagesc(hc, im);
    colorbar('peer', hc);
  end

  % Interpolate to get the slice
  cslice = interp2(xx0, yy0, im, xxR, yyR);
  cslice(isnan(cslice)) = 0.0;
  cslice = sum(cslice, 1);

  % Calculate the spectrum of the slice
  fftcslice = fft(cslice);
  fftcslice = fftcslice(1:ceil(length(fftcslice)/2));

  % Extract the fringe
  phase(ii) = angle(fftcslice(p.Results.freq_index));

  % Plot the frequency spectrum
  if p.Results.show_spectrum
    semilogy(hs, 1:numel(fftcslice), abs(fftcslice).^2);
    hold(hs, 'on');
  end

  % Plot the progress
  if p.Results.show_progress
    plt.XData = 1:ii;
    plt.YData = unwrap(phase(1:ii));
    drawnow;
  end
end

% Discard phases we didn't evaluate
phase = phase(idx);

% Unwrap and normalize phase
phase = unwrap(-phase);
phase = phase - min(phase);

% Wrap lookup table
lt = otslm.utils.LookupTable(phase, valueTable(:, idx).');

