function pattern = randombin(sz, varargin)
% RANDOM creates a random binary pattern
%
% pattern = random(sz, ...) creates a random pattern with values 0 or 0.5.
%
% Optional named parameters:
%
%   'range'   [low, high]  specifies min and max values.

p = inputParser;
p.addParameter('range', [0, 0.5]);
p.parse(varargin{:});

high = p.Results.range(2);
low = p.Results.range(1);

pattern = (randi(2, sz) - 1) * (high-low) + low;
