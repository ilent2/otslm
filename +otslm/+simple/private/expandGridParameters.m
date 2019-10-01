function params = expandGridParameters(p)
% Expand input parser for grid parameters
%
% Expands the parameters needed for grid into a cell array.
% If the method finds a `type` parameter, only the first two
% characters are preserved.
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
    value = p.Results.(parameters{ii});
    
    % Type could be longer than 2 chars (such as 2dcart)
    if strcmpi(parameters{ii}, 'type') && numel(value) > 2
      value = value(1:2);
    end
    
    params{2*num+2} = value;
    num = num + 1;
  end
end
