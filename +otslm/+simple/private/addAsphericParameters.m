function p = addAsphericParameters(p, sz, varargin)
% Add parameters for the aspheric function
%
% p = addGridParameters(p, ...) add grid parameters to the inputParser
% object p.
%
% Function parameters:
%   'skip'    {}    Cell array of names to skip in input parser
%   parameter_name   default_value    specify default value for parameter
%
% Aspheric parameters:
%   'alpha'       [a1, ...]   additional parabolic correction terms
%   'scale'       scale       scaling value for the final pattern
%   'delta'       delta       offset for the final pattern (default: 0.0)
%   'background'  img         Specifies a background pattern to use for
%       values outside the lens.  Can also be a scalar, in which case
%       all values are replaced by this value; or a string with
%       'random' or 'checkerboard' for these patterns.
%
% Grid parameters:
%   'centre'      [x, y]      centre location for lens
%   'offset'      [x, y]      offset after applying transformations
%   'type'        type        is the lens cylindrical or spherical (1d or 2d)
%   'aspect'      aspect      aspect ratio of lens (default: 1.0)
%   'angle'       angle       Rotation angle about axis (radians)
%   'angle_deg'   angle       Rotation angle about axis (degrees)
%   'gpuArray'    bool        If the result should be a gpuArray
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

parameters = {'centre', 'offset', 'type', 'aspect', 'angle', ...
  'angle_deg', 'gpuArray', 'alpha', 'delta', 'scale', 'background'};

% Allow user to change input parser defaults
ip = inputParser;

% Grid parameters
ip.addParameter('centre', [ sz(2)/2, sz(1)/2 ]);
ip.addParameter('offset', [0, 0]);
ip.addParameter('type', '2d');
ip.addParameter('aspect', 1.0);
ip.addParameter('angle', []);
ip.addParameter('angle_deg', []);
ip.addParameter('gpuArray', false);

% Aspheric parameters
ip.addParameter('alpha', []);
ip.addParameter('delta', 0.0);
ip.addParameter('scale', 1.0);
ip.addParameter('background', 0.0);

ip.addParameter('skip', {});
ip.parse(varargin{:});

% Add parameters to result input parser
for ii = 1:length(parameters)
  if ~any(strcmpi(parameters{ii}, ip.Results.skip))
    p.addParameter(parameters{ii}, ip.Results.(parameters{ii}));
  end
end
