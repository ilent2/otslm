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

function im = scan1d(slm, cam, varargin)

  p = inputParser;
  p.addParameter('width', 10);
  p.addParameter('stride', 1);
  p.addParameter('padding', []);
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
      disp(['Iteration: ' num2str(ii) ]);
    end

    % Generate pattern
    pattern = otslm.simple.aperture(slm.size, [rwidth, Inf], ...
        'type', 'rect', 'angle', angle_rad, ...
        'offset', [offset(ii), 0]);

    % Display the pattern and acquire image
    slm.showComplex(pattern);
    camim = cam.viewTarget();

    % Store the result
    im(ii) = sum(camim(:));

  end

end

function im = scan2d(slm, cam, varargin)
%
% padding   [x0 x1 y0 y1]

  p = inputParser;
  p.addParameter('width', [10, 10]);
  p.addParameter('stride', [1, 1]);
  p.addParameter('padding', []);
  p.addParameter('angle', []);
  p.addParameter('angle_deg', []);
  p.addParameter('verbose', true);
  p.parse(varargin{:});

  % Parse width
  rwidth = p.Results.width;
  if numel(rwidth) == 1
    rwidth = [rwidth, rwidth];
  end

  % Parse stride
  stride = p.Results.stride;
  if numel(stride) == 1
    stride = [stride, stride];
  end

  % Parse padding
  padding = p.Results.padding;
  if isempty(padding)
    padding = rwidth;
  elseif numel(padding) == 1
    padding = [padding, padding];
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
  width(1) = slm.size(1)*sin(angle_rad) + slm.size(2)*cos(angle_rad);
  width(2) = slm.size(1)*cos(angle_rad) + slm.size(2)*sin(angle_rad);
  
  offsetx = 1:stride:abs(width(1))+padding(1);
  offsetx = offsetx - 1 + rwidth(1)/2 - padding(1) - abs(width(1))/2;
  
  offsety = 1:stride:abs(width(2))+padding(2);
  offsety = offsety - 1 + rwidth(2)/2 - padding(2) - abs(width(2))/2;

  im = zeros(length(offsety), length(offsetx));

  for ii = 1:length(offsetx)
    for jj = 1:length(offsety)
      
      if p.Results.verbose
        disp(['Iteration: [' num2str(jj) ', ' num2str(ii) ']']);
      end

      % Generate pattern
      pattern = otslm.simple.aperture(slm.size, rwidth, ...
          'type', 'rect', 'angle', angle_rad, ...
          'offset', [offsetx(ii), offsety(jj)]);

      % Display the pattern and acquire image
      slm.showComplex(pattern);
      camim = cam.viewTarget();

      % Store the result
      im(jj, ii) = sum(camim(:));
    end
  end

end

