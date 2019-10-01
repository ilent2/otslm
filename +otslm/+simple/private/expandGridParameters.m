function params = expandGridParameters(p)
% Expand input parser for grid parameters
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

parameters = {'centre', 'offset', 'type', 'aspect', 'angle', ...
  'angle_deg', 'gpuArray'};

num = 0;
for ii = 1:length(parameters)
  if isfield(p.Results, parameters{ii})
    params{2*num+1} = parameters{ii};
    params{2*num+2} = p.Results.(parameters{ii});
    num = num + 1;
  end
end
