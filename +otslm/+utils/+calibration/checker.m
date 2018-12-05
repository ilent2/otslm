function lt = checker(slm, cam, varargin)
% CHECKER generate phase device lookup table using checkerboard pattern
%
% This method displays a checkerboard pattern on the device and looks
% at the intensity of the zero-th order.  This may not be very effective
% if the device is not efficient or the device doesn't cover the full
% 2*pi phase range.
%
% Optional named arguments:
%   spacing           num     size of checkerboard grid
%   delay             num     delay after updating slm
%   stride            num     number of linear indexes to step
%
%   verbose           bool    display progress in console
%   show_progress     bool    display progress of the method
%   show_camera       bool    show what the camera sees
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Parse method arguments
p = inputParser;
p.addParameter('spacing', 1);
p.addParameter('delay', []);
p.addParameter('stride', 1);
p.addParameter('verbose', true);
p.addParameter('show_progress', false);
p.addParameter('show_camera', false);
p.parse(varargin{:});

% For this method we do the same procedure twice to classify points
% in the range |phase| = 0 <= pi, then again for |phase-pi/2| = 0 <= pi.
% The actual phase is then
%
%   0   pi/2
%   <     <   0 - pi/2
%   >     <   pi/2 -> pi
%   >     >   pi -> 3pi/2
%   <     >   3pi/2 -> 2pi

% Generate the checkerboard
mask = otslm.simple.checkerboard(slm.size, 'value', [false, true], ...
		'spacing', p.Results.spacing);

% Generate full value table
valueTable = slm.linearValueRange('structured', true);

% Create a figure to track the progress
if p.Results.show_progress
	hf = figure();
	h = axes(hf);

	% Create plots for each sample run
	plt1 = plot(h, 0, 0);
	hold on;
	plt2 = plot(h, 0, 0);
	hold off;

	xlabel(h, 'linear pixel range');
	ylabel(h, 'Intensity');
	title(h, 'Checker calibration progress');

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

if p.Results.show_camera
	hcf = figure();
	hc = axes(hcf);
end

idx = 1:p.Results.stride:size(valueTable, 2);

% Rank everything in region 1
idx1 = 1;
phase1 = zeros(size(valueTable, 2), 1);
for ii = 1:p.Results.stride:size(valueTable, 2)

	if ~figure_active()
		error('Terminated by user');
	end

  % Display output to terminal
  if p.Results.verbose
    disp(['Checker calibration (part 1): ', num2str(ii), ...
        '/', num2str(size(valueTable, 2))]);
  end

	% Generate pattern
  ipattern = ones(slm.size).*idx1;
  ipattern(mask) = ii;

	% Show pattern and get image
	slm.showIndexed(ipattern);

	% Allow for a finite device response rate
	if ~isempty(p.Results.delay)
		pause(p.Results.delay);
	end

	% Acquire image from camera
	im = cam.viewTarget();

	% Show the camera image
	if p.Results.show_camera
		imagesc(hc, im);
		colorbar('peer', hc);
	end

	% Calculate intensity in target region
	phase1(ii) = sum(im(:));

	% Plot the progress
	if p.Results.show_progress
		plt1.XData = 1:ii;
		plt1.YData = phase1(1:ii);
		drawnow;
	end

end
phase1 = phase1(idx) - min(phase1(idx));

% Choose a region 2 and rank everything in this region
[~, idx2] = min(abs(phase1 - max(phase1)/2));
idx2 = (idx2-1)*p.Results.stride + 1;
phase2 = zeros(size(valueTable, 2), 1);
for ii = 1:p.Results.stride:size(valueTable, 2)

	if ~figure_active()
		error('Terminated by user');
	end

  % Display output to terminal
  if p.Results.verbose
    disp(['Checker calibration (part 2): ', num2str(ii), ...
        '/', num2str(size(valueTable, 2))]);
  end

	% Generate pattern
  ipattern = ones(slm.size).*idx2;
  ipattern(mask) = ii;

	% Show pattern and get image
	slm.showIndexed(ipattern);

	% Allow for a finite device response rate
	if ~isempty(p.Results.delay)
		pause(p.Results.delay);
	end

	% Calculate intensity in target region
	im = cam.viewTarget();

	% Show the camera image
	if p.Results.show_camera
		imagesc(hc, im);
		colorbar('peer', hc);
	end

	% Calculate intensity in target region
	phase2(ii) = sum(im(:));

	% Plot the progress
	if p.Results.show_progress
		plt2.XData = 1:ii;
		plt2.YData = phase2(1:ii);
		drawnow;
	end

end
phase2 = phase2(idx) - min(phase2(idx));

% Determine which region points are in
phase2small = phase2 - max(phase2)/2 < 0;

% Convert from intensity to phase
phase = sqrt(phase1./max(phase1));
phase(~phase2small) = -phase(~phase2small);
phase = unwrap(2*acos(-phase));
phase = phase - min(phase);

% Wrap lookup table
lt = otslm.utils.LookupTable(phase, valueTable(:, idx).');

