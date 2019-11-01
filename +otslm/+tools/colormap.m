function pattern = colormap(pattern, cmap, varargin)
% Applies a colormap to a pattern.
%
% This method either applies nearest value interpolation or uses a
% predefined lookup table.
%
% If a discrete colormap is provided, only values present in the
% colormap are used for the output pattern, allowing the colormap to
% contain discrete device specific values.
%
% Usage
%   pattern = colormap(pattern, colormap, ...) applies the colormap to
%   the pattern.  The input pattern should have a typical range from 0 to 1.
%   If the colormap is a LookupTable, the input pattern is scaled by the
%   lookup table range.
%
% Parameters
%   - pattern (numeric) -- the pattern to be converted
%   - colormap (LookupTable|numeric|cell|enum) -- colormap to apply.
%     The way colormaps are applied depends on the colormap type:
%    - LookupTable -- Uses phase, value and range properties of
%      the :class:`utils.LookupTable` object.
%    - numeric -- assumes colormap is a vector of equally spaced values
%      for the phase corresponding to pattern values between 0 and 1.
%    - cell -- assumes colormap is a 2 element cell array.  The first
%      element is a vector with pattern values (range 0 to 1) and the
%      second column is the corresponding output values.
%    - enum -- 'pmpi', '2pi', 'bin' or 'gray' for output range between
%      plus/minus pi, 0 to 2pi, binary, or grayscale (unchanged).
%
% Optional named parameters
%   - 'inverse' (logical) -- Apply inverse colormap.  The output will have
%     a typical range from 0 to 1.  Not implemented for all colormap types.

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('inverse', false);
p.parse(varargin{:});

% Check that we actually have a colormap
if isempty(cmap)
  return;  % Nothing to do
end

% Apply colour map
if ischar(cmap)

  if ~p.Results.inverse
    switch cmap
      case 'pmpi'
        pattern = pattern*2*pi - pi;
      case '2pi'
        pattern = pattern*2*pi;
      case 'bin'
        pattern = otslm.tools.dither(pattern, 0.5*max(pattern(:)));
      case 'gray'
        % Nothing to do
      otherwise
        error('Unrecognized colormap string');
    end
  else
    switch cmap
      case 'pmpi'
        pattern = (pattern + pi)./(2*pi);
      case '2pi'
        pattern = pattern./(2*pi);
      case 'bin'
        warning('Unable to generate inverse of binary colormap');
      case 'gray'
        % Nothing to do
      otherwise
        error('Unrecognized colormap string');
    end
  end
else

  % Allow for non-linear color maps
  if isa(cmap, 'otslm.utils.LookupTable')
    crange = cmap.phase(:)./cmap.range;
    cmap = cmap.value;
    assert(size(crange, 1) == size(cmap, 1), ...
        'otslm:tools:colormap:size', ...
        'Colour map must have same number of rows as crange values');
  elseif iscell(cmap)
    crange = cmap{1}(:);
    cmap = cmap{2};
    assert(size(crange, 1) == size(cmap, 1), ...
        'otslm:tools:colormap:size', ...
        'Colour map must have same number of rows as crange values');
  else
    % TODO: This case could be faster, we don't need to use interp1
    crange = linspace(0, 1, size(cmap, 1));
  end

  % Swap order if doing inverse mapping
  if p.Results.inverse
    [cmap, crange] = deal(crange, cmap);
  end

  % Calculate size of output image
  sz = size(pattern);
  if size(cmap, 2) ~= 1
    sz = [sz, size(cmap, 2)];
  end

  % Check range of inputs
  if ~p.Results.inverse
    if max(pattern(:)) > 1
      warning('Capping max value to 1');
      pattern(pattern > 1) = 1.0;
    end
    if min(pattern(:)) < 0
      warning('Capping min value to 0');
      pattern(pattern < 0) = 0.0;
    end
  end

  % Apply colour map
  pattern = interp1(crange, double(cmap), pattern(:), 'nearest');

  % Ensure output has the correct type
  pattern = cast(pattern, 'like', cmap);

  % Reshape to correct size
  pattern = reshape(pattern, sz);
end

