function pattern = sample_region(sz, locations, detectors, varargin)
% SAMPLE_REGION generates a pattern for sampling regions on SLM.
%
% pattern = sample_region(sz, locations, detectors, ...) generates
% the patterns for sampling regions at different SLM locations
% onto detectors located at detector locations.
%
% If detectors is a single location, all the patterns will point to
% the same detector.
%
% Locations should be in pixels.  TODO: units for detectors.
%
% Most optional named parameters can also be cell arrays (or cell arrays of
% cell arrays) for different options for each location.
%
% Optional named parameters:
%
%   'radii'       [r, ...]      Radius of each SLM region
%   'amplitude'   method        Specifies a method for amplitude modulation.
%   'ampliutdeargs', args       Amplitude method arguments.
%   'background'  type          Specifies the background type.
%       Possible values are:
%           'zero'            Uses 0 phase as the background.
%           'nan'             Uses NaN phase as the background.
%           'checkerboard'    Uses a checkerboard for the background.
%           'random'          Uses noise for the background.
%           'randombin'       Uses binary noise for the background.
%
% Possible amplitude methods are:
%   'step'              Sharp step between background and pattern
%
%   'gaussian_dither'   Randomly mixes in background
%     Args:
%       'offset'
%       'noise'
%
%   'gaussian_noise'   Adds noise to edge
%       of the pattern.  The type must be 'uniform' or 'gaussian'
%       for uniform noise or Gaussian noise.  The scale is the
%       uniform noise range or Gaussian width.
%     Args:
%       'offset'
%       'scale'
%       'type'
%
%   'gaussian_scale'  Scales the pattern by a Gaussian
%       and then uses the mix method to combine the pattern with
%       the background.  The mix method must be 'add' for
%       adding the result to the background, or 'step' for
%       placing the scaled pattern on the background as a step.
%     Args:
%       'mix'
%       'mixargs'
%       'scale'
%
% TODO: Documentation in this function
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Parse inputs
p = inputParser;
p.addParameter('radii', 0.1*min(sz));
p.addParameter('amplitude', 'step');
p.addParameter('amplitudeargs', {});
p.addParameter('background', 'zero');
p.parse(varargin{:});

% Ensure the number of detectors matches the number of locations
if length(detectors) == 1
  detectors = repmat(detectors, length(locations), 1);
end
assert(length(detectors) == length(locations), 'Not eneough detectors');

% Ensure the number of radii matches the number of locations
radii = p.Results.radii;
if length(radii) == 1
  radii = repmat(radii, length(locations), 1);
end
assert(length(radii) == length(locations), 'Not enough radii');

% Ensure the number of blur methods matches the number of locations
bmethods = p.Results.amplitude;
if ~isempty(bmethods)
  if ischar(bmethods)
    bmethods = {bmethods};
  end
  if ischar(bmethods{1})
    [tbmethods{1:length(locations)}] = deal(bmethods);
    bmethods = tbmethods;
  elseif length(bmethods) == 1 && length(locations) ~= 1
    [tbmethods{1:length(locations)}] = deal(bmethods);
    bmethods = tbmethods;
  end
end
assert(length(bmethods) == length(locations), 'Not enough amplitude methods');

% Ensure the number of blur method arguments matches the number of locations
bmethodargs = p.Results.amplitudeargs;
if ~isempty(bmethodargs)
  if ischar(bmethodargs)
    bmethodargs = {bmethodargs};
  end
  if ischar(bmethodargs{1})
    [tbmethods{1:length(locations)}] = deal(bmethodargs);
    bmethodargs = tbmethods;
  elseif length(bmethodargs) == 1 && length(locations) ~= 1
    [tbmethods{1:length(locations)}] = deal(bmethodargs);
    bmethodargs = tbmethods;
  end
else
  [tbmethods{1:length(locations)}] = deal({});
  bmethodargs = tbmethods;
end
assert(length(bmethodargs) == length(locations), ...
    'Not enough amplitude method arguments');

% Generate background
switch p.Results.background
  case 'zero'
    pattern = zeros(sz);
  case 'nan'
    pattern = zeros(sz) * NaN;
  case 'random'
    pattern = otslm.simple.random(sz);
  case 'randombin'
    pattern = otslm.simple.random(sz, 'type', 'binary');
  case 'checkerboard'
    pattern = otslm.simple.checkerboard(sz);
  otherwise
    error('Unknown background type specified');
end

% Generate the pattern for each location

for ii = 1:length(locations)

  loc = locations{ii};
  target = detectors{ii};
  radius = radii(ii);
  method = bmethods{ii};
  methodargs = bmethodargs{ii};

  linear = otslm.simple.linear(sz, norm(target), 'angle', atan2(target(2), target(1)));
  linear = otslm.tools.finalize(linear);

  switch method{1}
    case 'step'

      % Mask the grating and place it in the pattern
      mask = otslm.simple.aperture(sz, radius, ...
          'type', 'circle', 'centre', loc);
      pattern(mask) = linear(mask);

    case 'gaussian_dither'
      
      pa = inputParser;
      pa.addParameter('offset', 0.0);
      pa.addParameter('noise', 0.3);
      pa.parse(methodargs{:});
      
      % Create a gaussian image between 0 and 1
      gaussian = otslm.simple.gaussian(sz, radius, 'centre', loc);
      gaussian = gaussian ./ max(gaussian(:));
      
      % Add some noise to the Gaussian
      noise = otslm.simple.random(sz, 'type', 'uniform');
      gaussian = gaussian + noise * pa.Results.noise;
      
      % Generate the mask and mix in the linear pattern
      mask = gaussian > 0.5 + pa.Results.offset;
      pattern(mask) = linear(mask);
      
    case 'gaussian_noise'
      
      pa = inputParser;
      pa.addParameter('offset', 0.0);
      pa.addParameter('scale', 1.0);
      pa.addParameter('type', 'uniform');
      pa.parse(methodargs{:});
      
      gaussian = otslm.simple.gaussian(sz, radius, 'centre', loc);
      
      gaussian = 1.0 - gaussian ./ max(gaussian(:)) + pa.Results.offset;
      gaussian(gaussian > 1.0) = 1.0;
      gaussian(gaussian < 0.0) = 0.0;
      
      noise = otslm.simple.random(sz, 'type', pa.Results.type) .* gaussian;
      
      % Modify the layer
      layer = linear + pa.Results.scale * noise;
      
      % Use the masking method to add the region
      mask = otslm.simple.aperture(sz, 1.5*radius, ...
          'type', 'circle', 'centre', loc);
      pattern(mask) = layer(mask);
      
    case 'gaussian_scale'
      
      pa = inputParser;
      pa.addParameter('scale', 1.0);
      pa.addParameter('mix', 'add');
      pa.addParameter('mixargs', 1.5*radius);
      pa.parse(methodargs{:});
      
      gaussian = otslm.simple.gaussian(sz, radius, 'centre', loc);
      gaussian = gaussian ./ max(gaussian(:));
      
      layer = gaussian .* pa.Results.scale .* linear;
      
      switch pa.Results.mix
        case 'add'
          pattern = pattern + layer;
        case 'sadd'
        
          % add with scaled background too
          pattern = pattern .* (1.0 - gaussian)*pa.Results.scale;
          pattern = pattern + layer;
          
        case 'step'
          mask = otslm.simple.aperture(sz, pa.Results.mixargs, ...
              'type', 'circle', 'centre', loc);
          pattern(mask) = layer(mask);
        otherwise
          error('Unknown mix method for amplitude');
      end
    otherwise
      error('Unknown amplitude type specified');
  end

end

