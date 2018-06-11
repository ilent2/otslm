function pattern = random(sz, varargin)
% RANDOM creates a random pattern
%
% pattern = random(sz, ...) creates a random pattern with values between
% 0 and 1.
%
% Optional named parameters:
%
%   'range'   [low, high]  Range of values (default: [0, 1)).

p = inputParser;
p.addParameter('range', [0, 1]);
p.parse(varargin{:});

high = p.Results.range(2);
low = p.Results.range(1);

pattern = rand(sz) * (high-low) + low;
