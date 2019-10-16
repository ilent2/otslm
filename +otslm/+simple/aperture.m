function pattern = aperture(sz, dimension, varargin)
% Generates different shaped aperture patterns/masks
%
% Usage
%   pattern = aperture(sz, dimension, ...) creates a circular aperture with
%   radius given by parameter dimension.  Array is logical array.
%
% Parameters
%   - sz -- size of the pattern ``[rows, cols]``
%   - dimension -- List of numbers describing the aperture size.
%     Lens of the list depends on the aperture shape.  For a circle
%     dimensions is one element, the radius of the circle.
%
% Optional named parameters
%   - 'shape' -- Shape of aperture to generate. See supported shapes bellow.
%   - 'value'       [l, h]  --  values for off and on regions (default: [])
%   - 'centre'      [x, y]  --  centre location for pattern
%   - 'offset'      [x, y]  --  offset in rotated coordinate system
%   - 'aspect'    (num)     --  aspect ratio of lens (default: 1.0)
%   - 'angle'     (num)     --  Rotation angle about axis (radians)
%   - 'angle_deg' (num)     --  Rotation angle about axis (degrees)
%   - 'gpuArray' (logical)  --  If the result should be a gpuArray
%
% Supported shapes [dimensions]
%   - 'circle'    [radius] -- Pinhole/circular aperture
%   - 'square'    [width]  -- Square with equal sides
%   - 'rect'      [w, h]   -- Rectangle with width and height
%   - 'ring'      [r1, r2] -- Ring specified by inner and outer radius

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p = addGridParameters(p, sz, 'skip', 'type');
p.addParameter('shape', 'circle');
p.addParameter('value', []);
p.parse(varargin{:});

% Calculate coordinates
gridParameters = expandGridParameters(p);
[xx, yy, rr] = otslm.simple.grid(sz, gridParameters{:});

% Generate the pattern

switch p.Results.shape
  case 'circle'
    assert(length(dimension) == 1, 'Circle must have only one parameter');
    pattern = rr < dimension;
  case 'square'
    assert(length(dimension) == 1, 'Square must have only one parameter');
    pattern = abs(xx) < dimension & abs(yy) < dimension;
  case 'rect'
    assert(length(dimension) == 2, 'Rectangle must have two parameters');
    pattern = abs(xx) < dimension(1) & abs(yy) < dimension(2);
  case 'ring'
    assert(length(dimension) == 2, 'Ring must have two parameters');
    pattern = rr > dimension(1) & rr < dimension(2);
  otherwise
    error('Unknown shape argument');
end

% Scale the pattern (convert from logical to double)
pattern = otslm.tools.castValue(pattern, p.Results.value);

