function pattern = hadamard(sz, u, v, varargin)
% Generate a two dimensional pattern based on a row of the Hadamard matrix.
%
% These patterns form an orthogonal basis of discrete binary patterns
% in Cartessian coordinates.  They can be used for implementing various
% imaging schemes such as Hadamard Single Pixel imaging.
%
% Usage
%   pattern = otslm.simple.hadamard(sz, u, v, ...) constructs a single
%   square Hadamard basis pattern starting at row 1 column 1.
%
% Parameters
%   - sz (2x1 numeric) -- size of the output pattern.
%     The Hadamard patterns should be square with width N satisfying
%     the condition either N, N/12 or N/20 is a power of 2; otherwise,
%     the total number of pixels should be a number satisfying the
%     same condition.  By default, the patterns are assumed to be
%     square and ``N = 2^floor(log2(min(sz)))``.  When sz is larger
%     than NxN, extra values are padded with ``padding_value``.
%
%   - u, v (numeric scalar) -- row and column index for Hadamard pattern.
%     For square patterns, these should be in the range ``[1, N]``, for
%     linear indexed patterns, v can be set to 1 and u is the pixel index.
%     Alternatively, for linear indexed patterns, u, v should be able
%     to be passed to ``sub2ind`` with size equal to ``target_size``.
%
% Optional named arguments
%   - padding_value (numeric) -- Value to use for padding for
%     values outside the ``target_size`` region.
%     Default: ``0``.
%   - target_size (2x1 numeric) -- Target size for the 2-D Hadamard
%     pattern.  See ``sz`` parameter for details.
%     Target size can be non-square, in which case linear indexing is used.
%     Default: ``[1,1] .* 2^floor(log2(min(sz)))``.
%   - value [l, h] -- Lower and upper values for pattern.
%     Default: ``[0, 1]``.
%   - indexing (enum) -- Type of indexing to use.  Either 'square' or 'linear'.
%     Default: 'square' unless target_size is non-square.
%   - order (enum) -- Ordering of patterns.
%     - hadamard -- Order the same as Matlab's hadamard function.
%     - bitrevorder -- Applies bit reversal to u and v.
%     - largetosmall -- Orders patterns by the size of the solid region,
%       large regions have lower u/v index, small regions have higher index.
%       Should produce the same result at linear indexing with 'hadamard'
%       ordering.
%     Default: 'largetosmall' for square indexing, 'hadamard' for linear.
%
%   - centre [x, y] -- centre location for pattern.
%     Default: ``[]`` for top corner, i.e. ``target_size/2 + [0.5, 0.5]``.
%   - offset [x, y] -- offset after applying transformations.
%     Default: [0, 0].
%   - scale (numeric) -- Scaling factor for the pattern.
%     Either a scalar or 2 element vector for [x, y] scaling.
%     Default: 1.0
%   - angle (numeric) -- Rotation angle about axis (radians) (default: 0.0).
%   - angle_deg (numeric) -- Rotation angle about axis (degrees).
%   - aspect (numeric) -- Aspect ratio of pattern (default: 1.0)

% Copyright 2020 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p = addGridParameters(p, sz, 'skip', {'type', 'gpuArray'}, ...
  'centre', []);
p.addParameter('padding_value', 0);
p.addParameter('target_size', []);
p.addParameter('value', [0, 1]);
p.addParameter('indexing', []);
p.addParameter('order', []);
p.addParameter('scale', 1.0);
p.parse(varargin{:});

% Determine default target_size
target_size = p.Results.target_size;
if isempty(target_size)
  target_size = [1, 1] .* 2^floor(log2(min(sz)));
end
assert(numel(target_size) == 2, 'target_size must be 2 element vector');
assert(all(target_size == floor(target_size)), 'target_size must be integers');

% Determine default indexing
indexing = p.Results.indexing;
if isempty(indexing)
  if target_size(1) == target_size(2)
    indexing = 'square';
  else
    indexing = 'linear';
  end
end
assert(any(strcmpi(indexing, {'square', 'linear'})), ...
  'Indexing must be either square or linear');

% Determine default order
order = p.Results.order;
if isempty(order)
  if strcmpi(indexing, 'square')
    order = 'largetosmall';
  elseif strcmpi(indexing, 'linear')
    order = 'hadamard';
  end
end
assert(any(strcmpi(order, {'hadamard', 'bitrevorder', 'largetosmall'})), ...
  'Order must be either hadamard, bitrevorder or largetosmall');

% Check u and v value ranges
assert(isnumeric(u) && isscalar(u) && round(u) == u, ...
  'u should be numeric scalar integer');
assert(isnumeric(v) && isscalar(v) && round(v) == v, ...
  'v should be numeric scalar integer');
assert(u > 0, 'u should be positive');
assert(v > 0, 'v should be positive');

% Apply ordering conversions to u/v indices
switch order
  case 'hadamard'
    % Nothing to do

  case 'bitrevorder'
    % Might be a more optimal way, perhaps use bitrevorder?
    n = max(log2(target_size));
    u = bin2dec(flip(dec2bin(u-1, n)))+1;
    v = bin2dec(flip(dec2bin(v-1, n)))+1;

  case 'largetosmall'
    u = bitxor(bitshift(u-1, -1), u-1)+1;
    v = bitxor(bitshift(v-1, -1), v-1)+1;

    % Reverse the bits too
    n = max(log2(target_size));
    u = bin2dec(flip(dec2bin(u-1, n)))+1;
    v = bin2dec(flip(dec2bin(v-1, n)))+1;

  otherwise
    error('Unrecognised order argument');
end

% Calculate Hadamard matrix
% TODO: We don't need the whole matrix, we just need one or two rows
switch indexing
  case 'linear'
    H = -hadamard(prod(target_size))/2 + 0.5;

    row = (v-1)*target_size(1) + u;
    assert(row <= size(H, 1), ...
      '(v-1)*target_size(1) + u must be less than/equal to num-pixels');
    
    pattern = reshape(H(row, :), target_size);

  case 'square'
    assert(u <= target_size(1), 'u should be less than target_size(1)');
    assert(v <= target_size(1), 'v should be less than target_size(1)');
    
    H = hadamard(target_size(1))/2 + 0.5;
    pattern = mod(H(u, :).' + H(v, :), 2);

  otherwise
    error('Unrecognized indexing argument');

end

% Scale pattern values
pattern = pattern .* diff(p.Results.value) + p.Results.value(1);

% Pack pattern into target (and use padding)
xl = (1:target_size(2)) - target_size(2)./2 - 0.5;
yl = (1:target_size(1)) - target_size(1)./2 - 0.5;

% Handle default value for centre
centre = p.Results.centre;
if isempty(centre)
  centre = target_size/2 + [0.5, 0.5];
end

gridParameters = expandGridParameters(p);
[xx, yy] = otslm.simple.grid(sz, gridParameters{:}, ...
  'centre', centre);

scale = p.Results.scale;
if isscalar(scale)
  scale = [scale, scale];
end

pattern = interp2(xl.*scale(1), yl.*scale(2), pattern, xx, yy, 'nearest');
pattern(isnan(pattern)) = p.Results.padding_value;

end

