function pattern = mask_regions(base, patterns, locations, sizes, varargin)
% Adds patterns to base using masking
%
% Usage
%   pattern = mask_region(base, patterns, locations, sizes, ...)
%
% Parameters
%   - base (numeric) -- base pattern to mask and add regions to
%   - patterns (cell) -- cell array of patterns to be added.  Each pattern
%     must be the same size as base.  Patterns should be numeric.
%   - locations (cell) -- cell array containing vectors for the centre
%     of each mask region.  Must be the same length as patterns.
%   - sizes -- size parameters for each shape (see options below).
%     Number of sizes must be 1 (for a single shape) or match the
%     length of patterns.
%
% Optional named parameters
%   - 'shape' (cell|enum) -- shape to use for masking.  Must either be
%     a single shape or a cell array of shapes with the same number of
%     elements as patterns.  Supported shapes and [sizes] include:
%    - 'circle'    [radius]    Use a circular aperture.
%    - 'square'    [width]     Square with equal sides.
%    - 'rect'      [w, h]      Rectangle with width and height.

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

