function pattern = random(sz, varargin)
% RANDOM generates a random pattern
%
% pattern = random(sz, ...) creates a pattern with uniform random
% noise values between 0 and 1.
%
% Optional named parameters:
%
%   'range'   [low, high]  Range of values (default: [0, 1)).
%   'type'    type         Type of noise.  Can be 'uniform',
%       'gaussian', or 'binary'.  (default: 'uniform')
%   'gpuArray'    bool        If the result should be a gpuArray
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('range', [0, 1]);
p.addParameter('type', 'uniform');
p.addParameter('gpuArray', false);
p.parse(varargin{:});

high = p.Results.range(2);
low = p.Results.range(1);

switch p.Results.type
  case 'uniform'
    if p.Results.gpuArray
      noise = gpuArray.rand(sz);
    else
      noise = rand(sz);
    end
    pattern = noise * (high-low) + low;
  case 'gaussian'
    if p.Results.gpuArray
      noise = gpuArray.randn(sz);
    else
      noise = randn(sz);
    end
    pattern = noise * (high-low) + (high + low)/2.0;
  case 'binary'
    if p.Results.gpuArray
      noise = gpuArray.randi(sz);
    else
      noise = randi(sz);
    end
    pattern = (noise - 1) * (high-low) + low;
  otherwise
    error('Unknown noise type');
end

% Ensure resulting pattern has correct type
pattern = cast(pattern, class(p.Results.range));
