function im = scan1d(slm, cam, varargin)
% Scans a bar region across device.
%
% This function scans a vertical stripe across the surface of the SLM with
% flat phase. Pixels outside this region are assigned a random phase, a
% checkerboard pattern or some other pattern in order to scatter light
% away from the zero order. The camera (or a photo-diode) should be placed
% in the far-field to capture only light from the flat phase region. This
% function generates a 1-D profile of the light on the SLM.
%
% Usage
%   im = scan1d(slm, cam, ...) scans a bar region across the device
%   and returns a array representing the intensities at each location.
%
% Parameters
%   - slm (:class:`Showable`) -- device to display pattern on.
%     The slm.showComplex function is used to display the pattern.
%     The pattern used for pixels outside the main region depends on
%     the SLM configuration.
%   - cam (:class:`Viewable`) -- device viewing the display.  This device
%     could be a single photo-diode or the average intensity from all
%     pixels on a camera.
%
% Optional named arguments
%  - width (numeric)     -- width of the region to scan across the device
%  - stride (numeric)    -- number of pixels to step
%  - padding (numeric)   -- offset for initial window position
%  - delay (numeric)     -- number of seconds to delay after displaying the
%    image on the SLM before imaging (default: [], i.e. none)
%  - angle (numeric)     -- direction to scan in (rad)
%  - angle_deg (numeric) -- direction to scan in (deg)
%  - verbose (logical)   -- display additional information about run
%
% See also :func:`image2d`.

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

assert(isa(slm, 'otslm.utils.Showable') && isvalid(slm), ...
  'slm must be a valid otslm.utils.Showable');
assert(isa(cam, 'otslm.utils.Viewable') && isvalid(cam), ...
  'cam must be a valid otslm.utils.Viewable');

p = inputParser;
p.addParameter('width', 10);
p.addParameter('stride', 1);
p.addParameter('padding', []);
p.addParameter('delay', []);
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
p.addParameter('verbose', true);
p.parse(varargin{:});

rwidth = p.Results.width;
stride = p.Results.stride;

% Parse padding, setting default argument if required
padding = p.Results.padding;
if isempty(padding)
	padding = rwidth;
end

% Parse angle arguments
angle_rad = [];
if isempty(angle_rad)
	angle_rad = p.Results.angle;
end
if isempty(angle_rad)
	angle_rad = p.Results.angle_deg * pi/180;
end
if isempty(angle_rad)
	angle_rad = 0;
end
angle_rad = angle(exp(1i*angle_rad));

% Calculate width of device (in rotated coordinates)
width = slm.size(1)*sin(angle_rad) + slm.size(2)*cos(angle_rad);

offset = 1:stride:abs(width)+padding;
offset = offset - 1 + rwidth/2 - padding - abs(width)/2;

im = zeros(length(offset), 1);

for ii = 1:length(offset)

	if p.Results.verbose
		disp(['Scan1d: ' num2str(ii) ' / ' num2str(length(offset)) ]);
	end

	% Generate pattern
	pattern = otslm.simple.aperture(slm.size, [rwidth/2, Inf], ...
			'shape', 'rect', 'angle', angle_rad, ...
			'offset', [offset(ii), 0]);

	% Display the pattern and acquire image
	slm.showComplex(pattern);
  if ~isempty(p.Results.delay)
  	pause(p.Results.delay);
  end
	camim = cam.viewTarget();

	% Store the result
	im(ii) = sum(camim(:));

end

