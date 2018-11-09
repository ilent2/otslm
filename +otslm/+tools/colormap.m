function pattern = colormap(pattern, cmap, varargin)
% COLORMAP applies a colormap to a pattern
%
% pattern = colormap(pattern, colormap, ...)
%
% Optional named parameters:
%   'inverse'   bool    Apply inverse colormap
%
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
  if iscell(cmap)
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
  if max(pattern(:)) > 2
    warning('Capping max value to 1');
    pattern(pattern > 1) = 1.0;
  end
  if min(pattern(:)) < 0
    warning('Capping min value to 0');
    pattern(pattern < 0) = 0.0;
  end

  % Apply colour map
  pattern = interp1(crange, double(cmap), pattern(:), 'nearest');

  % Ensure output has the correct type
  pattern = cast(pattern, 'like', cmap);

  % Reshape to correct size
  pattern = reshape(pattern, sz);
end

