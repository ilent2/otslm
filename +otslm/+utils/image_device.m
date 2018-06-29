function im = image_device(slm, cam, varargin)
% IMAGE_DEVICE method to generate image of slm
%
% im = image_device(slm, cam, ...) generates an image of the
%
% Optional named parameters:
%
%   'method'      method      Method to use for imaging
%   'methodargs'  args        Method arguments
%   'slmformat'   format      Format to use for slm pattern
%       'raw'           Use slm.showRaw function
%       'complex'       Use slm.showComplex function (default)
%
% Supported methods:
%   'scan1d'   Scans a bar region across device
%   'scan2d'   Scans a aperture across device
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('method', 'scanap');
p.addParameter('methodargs', {});
p.addParameter('slmformat', 'complex');
p.parse(varargin{:});

switch p.Results.method
  case 'scan1d'
    im = scan1d(slm, cam, p.Results.slmformat, p.Results.methodargs{:});
  case 'scan2d'
    im = scan2d(slm, cam, p.Results.slmformat, p.Results.methodargs{:});
  otherwise
    error('Unknown method paremeter value');
end

end

function im = scan1d(slm, cam, slmformat, varargin)

  rwidth = 10;
  stride = 1;
  padding = 9;
  angle_rad = 0;

  % TODO: Check this, not quite finished...
  width = slm.size(1)*sin(angle_rad) + slm.size(2)*cos(angle_rad);

  % TODO: Use slmformat for displaying random values on other
  %   parts of the device

  im = zeros(slm.size(2)+padding, 1);

  for ii = 1:sign(width):slm.size(2)+padding

    % Generate pattern
    pattern = otslm.simple.aperture(slm.size, [rwidth, Inf], ...
        'type', 'rect', 'angle', angle_rad, 'centre', [ii-padding, 0]);

    % Display the pattern
    slm.showComplex(pattern);

    % Acquire an image of the result
    camim = cam.viewTarget();

    % Store the result
    im(ii) = sum(camim(:));

  end

end

function im = scan2d(slm, cam, slmformat, varargin)
  error('Not yet implemented');
end

