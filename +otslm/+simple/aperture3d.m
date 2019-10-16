function pattern = aperture3d(sz, dimension, varargin)
% Generate a 3-D volume similar to :func:`aperture`.
% Can be used to create a target 3-D volume for beam shape optimisation.
%
% Usage
%   pattern = aperture3d(sz, dimension, ...)
%
% Properties
%   - sz -- Size of the pattern ``[rows, cols, depth]``
%   - dimensions -- aperture dimensions (depends on aperture shape)
%
% Optional named parameters
%   - 'shape' -- Shape of aperture to generate. See supported shapes.
%   - 'value'       [l, h]    -- values for off and on regions (default: [])
%   - 'centre'      [x, y, z] -- centre location for pattern
%   - 'gpuArray'   (logical)  -- If the result should be a gpuArray
%
% Supported shapes [dimensions]
%    - 'sphere'  [radius]  -- Pinhole/circular aperture
%    - 'cube'    [width]   -- Square with equal sides
%    - 'rect'    [w, h, d] -- Rectangle with width and height
%    - 'shell'   [r1, r2]  -- Ring specified by inner and outer radius

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% TODO: Rotation and offset after rotation

assert(isnumeric(sz) && numel(sz) == 3, ...
  'sz must be numeric with have 3 elements');

p = inputParser;
p.addParameter('shape', 'sphere');
p.addParameter('value', []);
p.addParameter('centre', [sz(2), sz(1), sz(3)]/2.0);
p.addParameter('gpuArray', false);
p.parse(varargin{:});

% Calculate coordinates
gridParameters = expandGrid3dParameters(p);
[xx, yy, zz, rr] = otslm.simple.grid3d(sz, gridParameters{:});

% Generate pattern
switch p.Results.shape
  case 'sphere'
    assert(length(dimension) == 1, 'Sphere must have only one parameter');
    pattern = rr < dimension;
  case 'cube'
    assert(length(dimension) == 1, 'Cube must have only one parameter');
    pattern = abs(xx) < dimension ...
        & abs(yy) < dimension ...
        & abs(zz) < dimension;
  case 'rect'
    assert(length(dimension) == 3, 'Rectangle must have three parameters');
    pattern = abs(xx) < dimension(1) ...
        & abs(yy) < dimension(2) ...
        & abs(zz) < dimension(3);
  case 'shell'
    assert(length(dimension) == 2, 'Shell must have two parameters');
    pattern = rr > dimension(1) & rr < dimension(2);
  otherwise
    error('Unknown shape argument');
end

% Scale the pattern (convert from logical to double)
pattern = otslm.tools.castValue(pattern, p.Results.value);

