function f = intensity(target, trial, varargin)
% INTENSITY objective function to optimise for intensity
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('roi', @otslm.iter.objectives.roiAll);
p.parse(varargin{:});

% Apply mask to target and trial
[target, trial] = p.Results.roi(target, trial);

f = -1 * mean(abs(trial(:)).^2 .* abs(target(:)).^2);

end
