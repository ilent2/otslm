function pattern = mask_regions(base, patterns, locations, sizes, varargin)
% MASK_REGIONS adds patterns to base using masking
%
% pattern = mask_region(bas, patterns, locations, sizes, ...)
%
% Optional named parameters:
%
%   'shape'    shape      Shape to use for masking.
%       'circle'    [radius]    Use a circular aperture.
%       'square'    [width]     Square with equal sides
%       'rect'      [w, h]      Rectangle with width and height
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('shape', 'circle');
p.parse(varargin{:});

assert(numel(patterns) == numel(locations), 'Not enough locations');
assert(numel(patterns) == numel(sizes), 'Not enough sizes');
assert(ischar(p.Results.shape) || numel(p.Results.shape) == numel(sizes), ...
    'shape must be either single shape or cell array of shapes for each size');

for ii = 1:length(patterns)

  pattern = patterns{ii};
  loc = locations{ii};
  atype = p.Results.shape;
  if iscell(atype)
    atype = p.Results.shape{ii};
  end
  asize = sizes{ii};

  % Generate mask
  roi = otslm.simple.aperture(size(base), asize, ...
      'shape', atype, 'centre', loc);

  % Add pattern to base
  base(roi) = pattern(roi);

end

% Assign output variable
pattern = base;

