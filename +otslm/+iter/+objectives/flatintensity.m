function f = flatintensity(target, trial, varargin)
% FLATINTENSITY objective function for high flat intensity
%
% Optional named parameters:
%   flatness    ratio     Importance of flatness (default 0.5)
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('flatness', 0.5);
p.parse(varargin{:});

F = otslm.iter.objectives.flatness(target, trial);
I = otslm.iter.objectives.intensity(target, trial);

f = I + p.Results.flatness*F;

end
