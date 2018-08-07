function f = flatness(target, trial, varargin)
% FLATNESS objective function to optimise for flatness
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('roi', @otslm.iter.objectives.roiAll);
p.parse(varargin{:});

[target, trial] = p.Results.roi(target, trial);

T = abs(target(:)).^2;
I = abs(trial(:)).^2 .* T;
mI = mean(I);

f = sum(T) .* sqrt( mean(( I - mI ).^2) ) ./ mI;

end
