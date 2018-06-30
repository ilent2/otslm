function im = image_device(slm, cam, varargin)
% IMAGE_DEVICE method to generate image of slm
%
% im = image_device(slm, cam, ...) generates an image of the
%
% Optional named parameters:
%
%   'method'      method      Method to use for imaging
%   'methodargs'  args        Method arguments
%
% Supported methods:
%   'scan1d'   Scans a bar region across device
%   'scan2d'   Scans a aperture across device
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('method', 'scan1d');
p.addParameter('methodargs', {});
p.parse(varargin{:});

switch p.Results.method
  case 'scan1d'
    im = scan1d(slm, cam, p.Results.methodargs{:});
  case 'scan2d'
    im = scan2d(slm, cam, p.Results.methodargs{:});
  otherwise
    error('Unknown method paremeter value');
end

end

function im = scan1d(slm, cam, slmformat, varargin)

  p = inputParser;
  p.addParameter('width', 10);
  p.addParameter('stride', 1);
  p.addParameter('padding', []);
  p.addParameter('angle', []);
  p.addParameter('angle_deg', []);
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

  im = zeros(slm.size(2)+padding, 1);

  for ii = 1:stride:abs(width)+padding

    % Generate pattern
    pattern = otslm.simple.aperture(slm.size, [rwidth, Inf], ...
        'type', 'rect', 'angle', angle_rad, ...
        'offset', [ii-1+rwidth/2-padding - abs(width)/2, 0]);

    % Display the pattern and acquire image
    slm.showComplex(pattern);
    camim = cam.viewTarget();

    % Store the result
    im(ii) = sum(camim(:));

  end

end

function im = scan2d(slm, cam, slmformat, varargin)

  p = inputParser;
  p.addParameter('width', [10, 10]);
  p.addParameter('stride', [1, 1]);
  p.addParameter('padding', []);
  p.parse(varargin{:});

  % Parse width
  width = p.Results.width;
  if numel(width) == 1
    width = [width, width];
  end

  % Parse stride
  stride = p.Results.stride;
  if numel(stride) == 1
    stride = [stride, stride];
  end

  % Parse padding
  padding = p.Results.padding;
  if isempty(padding)
    padding = [width, width];
  elseif numel(padding) == 2
    padding = [padding, padding];
  elseif numel(padding) == 1
    padding = repmat(padding, [1, 4]);
  end

  % TODO: calculate numrows, numcols
  error('Not yet implemented');

  % Allocate memory for output
  im = zeros(numrows, numcols);

  for ii = 1:stride(1):numcols
    for jj = 1:stride(2):numrows

      % TODO: Generate pattern

      % Display the pattern and acquire image
      slm.showComplex(pattern);
      camim = cam.viewTarget();

      % Store the result
      im(jj, ii) = sum(camim(:));
    end
  end

end

