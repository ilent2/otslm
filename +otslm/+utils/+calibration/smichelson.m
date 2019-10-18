function lt = smichelson(slm, cam, varargin)
% Uses images from a sloped Michelson interferometer
%
% Calculate the SLM lookup table using interference fringes on a
% sloped Michelson interferometer setup.  Either the SLM or reference
% beam mirror must be sloped with respect to the illumination causing
% interference fringes in the output.  By varying the phase on the
% device, the fringes can be made to move.  This can be done on
% half the device allowing the other half to be used as a reference.
%
% Usage
%   lt = smichelson(slm, cam, ...) calibrate using the smichelson method.
%
% Parameters
%   - slm (:class:`Showable`) -- device to generate the lookup table for.
%   - cam (:class:`Viewable`) -- device imaging the slm.  The camera
%     should be viewing the output of a Michelson interferometer, with
%     the SLM on one arm and a mirror on the other.  The mirror should
%     be tilted slightly to create interference fringes on the camera.
%
% Optional named parameters
%   - slice1_offset   num  -- slice 1 distance from image centre
%   - slice1_width    num  -- width of the slice 1 to average over
%   - slice2_offset   num  -- slice 2 distance from image centre
%   - slice2_width    num  -- width of the slice 2 to average over
%   - slice_angle     num  -- angle for the slice (deg)
%   - freq_index      idx  -- index for frequency sample
%   - step_angle      num  -- angle for the step function (deg)
%   - delay           num  -- delay after displaying slm image
%   - stride          num  -- number of linear indexes to step
%   - basevalue       num  -- value to use for the first region
%
%   - verbose         bool -- display progress in console
%   - show_progress   bool -- show progress figure
%   - show_camera     bool -- show what the camera sees
%   - show_spectrum   bool -- show the 1-D Fourier spectrum of the images

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Parse method arguments
p = inputParser;
p.addParameter('slice1_offset', 0);
p.addParameter('slice1_width', 1);
p.addParameter('slice2_offset', 0);
p.addParameter('slice2_width', 1);
p.addParameter('slice_angle', 0);
p.addParameter('freq_index', 1);
p.addParameter('step_angle', 0);
p.addParameter('delay', []);
p.addParameter('stride', 1);
p.addParameter('verbose', true);
p.addParameter('show_progress', false);
p.addParameter('show_camera', false);
p.addParameter('show_spectrum', false);
p.addParameter('basevalue', 1);
p.parse(varargin{:});

assert(p.Results.stride >= 1 ...
  && p.Results.stride == round(p.Results.stride), ...
  'Stride must be positive non-zero integer');
assert(p.Results.slice1_width > 0, ...
  'Slice 1 width must be positive');
assert(p.Results.slice2_width > 0, ...
  'Slice 2 width must be positive');
assert(p.Results.basevalue >= 1 ...
  && p.Results.basevalue == round(p.Results.basevalue), ...
  'basevalue must be positive non-zero integer');

% Generate pattern we will use
% Only mask half the device so we have a reference
mask = otslm.simple.step(slm.size, 'value', [false, true], ...
  'angle_deg', p.Results.step_angle);

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
  title(h, 'Sloped Michelson calibration progress');

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
len = sqrt(imwidth.^2 + imheight.^2);
[xx0, yy0] = meshgrid(1:imwidth, 1:imheight);

offset = p.Results.slice1_offset;
swidth = p.Results.slice1_width;
[xx, yy] = meshgrid(-len/2:len/2, (0.5:(swidth-0.5)) + offset);
xxR1 = xx .* cos(theta) + imwidth/2 - yy .* sin(theta);
yyR1 = xx .* sin(theta) + imheight/2 + yy .* cos(theta);

offset = p.Results.slice2_offset;
swidth = p.Results.slice2_width;
[xx, yy] = meshgrid(-len/2:len/2, (0.5:(swidth-0.5)) + offset);
xxR2 = xx .* cos(theta) + imwidth/2 - yy .* sin(theta);
yyR2 = xx .* sin(theta) + imheight/2 + yy .* cos(theta);

% Measure phase of each value
idx = 1:p.Results.stride:size(valueTable, 2);
phase = zeros(size(valueTable, 2), 1);
for ii = 1:p.Results.stride:size(valueTable, 2)

  % Check if the user clicked cancel or closed the figure
  if ~figure_active()
    error('Terminated by user');
  end

  % Display output to terminal
  if p.Results.verbose
    disp(['Sloped Michelson calibration: ', num2str(ii), ...
        '/', num2str(size(valueTable, 2))]);
  end

  % Generate raw pattern
  ipattern = ones(slm.size).*p.Results.basevalue;
  ipattern(mask) = ii;

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

  % Interpolate to get the slice 1
  cslice1 = interp2(xx0, yy0, im, xxR1, yyR1);
  cslice1(isnan(cslice1)) = 0.0;
  cslice1 = sum(cslice1, 1);

  % Interpolate to get the slice 2
  cslice2 = interp2(xx0, yy0, im, xxR2, yyR2);
  cslice2(isnan(cslice2)) = 0.0;
  cslice2 = sum(cslice2, 1);

  % Calculate the spectrum of the slice
  fftcslice1 = fft(cslice1);
  fftcslice1 = fftcslice1(1:ceil(length(fftcslice1)/2));
  fftcslice2 = fft(cslice2);
  fftcslice2 = fftcslice2(1:ceil(length(fftcslice2)/2));

  % Extract the fringe
  phase(ii) = angle(fftcslice2(p.Results.freq_index)) ...
    - angle(fftcslice1(p.Results.freq_index));

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

