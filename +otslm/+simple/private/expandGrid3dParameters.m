function params = expandGrid3dParameters(p)
% Expand input parser for grid3d parameters
%
% Expands the parameters needed for grid into a cell array.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

parameters = {'centre', 'gpuArray'};

num = 0;
for ii = 1:length(parameters)
  if isfield(p.Results, parameters{ii})
    params{2*num+1} = parameters{ii};
    value = p.Results.(parameters{ii});
    
    % Consider adding type, do we need to filter value?
    
    params{2*num+2} = value;
    num = num + 1;
  end
end
