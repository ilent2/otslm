function p = addGrid3dParameters(p, sz, varargin)
% Add parameters for the grid function
%
% p = addGrid3dParameters(p, ...) add grid parameters to the inputParser
% object p.
%
% Named parameters:
%   'centre'      [x, y]      centre location for lens
%   'gpuArray'    bool        If the result should be a gpuArray
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

assert(numel(sz) == 3, 'sz must be 3 element vector');

parameters = {'centre', 'gpuArray'};

% Allow user to change input parser defaults
ip = inputParser;
ip.addParameter('centre', [ sz(2)/2, sz(1)/2, sz(3)/2 ]);
ip.addParameter('gpuArray', false);
ip.addParameter('skip', {});
ip.parse(varargin{:});

% Add parameters to result input parser
for ii = 1:length(parameters)
  if ~any(strcmpi(parameters{ii}, ip.Results.skip))
    p.addParameter(parameters{ii}, ip.Results.(parameters{ii}));
  end
end
