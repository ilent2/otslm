function params = expandAsphericParameters(p)
% Expand parser for aspheric parameters

parameters = {'centre', 'offset', 'type', 'aspect', 'angle', ...
  'angle_deg', 'gpuArray', 'alpha', 'delta', 'scale', 'background'};

num = 0;
for ii = 1:length(parameters)
  if isfield(p.Results, parameters{ii})
    params{2*num+1} = parameters{ii};
    params{2*num+2} = p.Results.(parameters{ii});
    num = num + 1;
  end
end