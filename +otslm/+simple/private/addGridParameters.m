function p = addGridParameters(p, sz, varargin)
% Add parameters for the grid function
%
% p = addGridParameters(p, ...) add grid parameters to the inputParser
% object p.
%
% Named parameters:
%   'centre'      [x, y]      centre location for lens
%   'offset'      [x, y]      offset after applying transformations
%   'type'        type        is the lens cylindrical or spherical (1d or 2d)
%   'aspect'      aspect      aspect ratio of lens (default: 1.0)
%   'angle'       angle       Rotation angle about axis (radians)
%   'angle_deg'   angle       Rotation angle about axis (degrees)
%   'gpuArray'    bool        If the result should be a gpuArray
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

assert(numel(sz) == 2, 'sz must be 2 element vector');

parameters = {'centre', 'offset', 'type', 'aspect', 'angle', ...
  'angle_deg', 'gpuArray'};

% Allow user to change input parser defaults
ip = inputParser;
ip.addParameter('centre', [ sz(2)/2, sz(1)/2 ]);
ip.addParameter('offset', [0, 0]);
ip.addParameter('type', '2d');
ip.addParameter('aspect', 1.0);
ip.addParameter('angle', []);
ip.addParameter('angle_deg', []);
ip.addParameter('gpuArray', false);
ip.addParameter('skip', {});
ip.parse(varargin{:});

% Add parameters to result input parser
for ii = 1:length(parameters)
  if ~any(strcmpi(parameters{ii}, ip.Results.skip))
    p.addParameter(parameters{ii}, ip.Results.(parameters{ii}));
  end
end
