function lt = step(slm, cam, varargin)
% STEP applies a step function and looks at interference
%
% Creates a phase pattern with two regions and looks at the interference
% of the regions.
%
% lt = step(slm, cam, ...) calibrates using the step method.
%
% Optional named arguments:
%		show_progress			bool 		show progress of the method
%		show_camera				bool		show what the camera sees
%		show_spectrum			bool		show the 1-D Fourier spectrum of the images
%		delay							num			delay after pattern is displayed
%		direction					num			1 or 2 for the direction to sum along
%		basevalue					num			value to use for the first region
%   sidx              num     slice index to calculate angle from
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Parse method arguments
p = inputParser;
p.addParameter('show_progress', true);
p.addParameter('show_camera', false);
p.addParameter('show_spectrum', false);
p.addParameter('delay', []);
p.addParameter('direction', 1);
p.addParameter('basevalue', 1);
p.addParameter('sidx', min(cam.roisize/2));
p.parse(varargin{:});

% Generate pattern we will use
pattern = logical(otslm.simple.step(slm.size, 'value', [0, 1]));

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

% Do full range test
phase = zeros(size(valueTable, 2), 1);
for ii = 2:size(valueTable, 2)

	if ~figure_active()
		error('Terminated by user');
	end

	% Generate raw pattern
  ipattern = ones(slm.size).*p.Results.basevalue;
  ipattern(pattern) = ii;

	% Display on slm and acquire image
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
	
	% Extract the fringe
	cslice = sum(im, p.Results.direction);
	fftcslice = fft(cslice);
	phase(ii) = angle(fftcslice(p.Results.sidx));
	
	% Plot the frequency spectrum
	if p.Results.show_spectrum
		loglog(hs, 1:numel(fftcslice), abs(fftcslice));
		hold(hs, 'on');
	end
	
	% Plot the progress
	if p.Results.show_progress
		plt.XData = 1:ii;
		plt.YData = unwrap(phase(1:ii));
		drawnow;
	end

end

% Unwrap and normalize phase
phase = unwrap(-phase);
phase = phase - min(phase);

% Wrap lookup table
lt = otslm.utils.LookupTable(phase, valueTable);

