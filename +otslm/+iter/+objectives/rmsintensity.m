function f = rmsintensity(target, trial, varargin)
% RMSINTENSITY objective function to optimise for intensity
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

roi = zeros(size(target), 'logical');
roi(1+end/4:end-end/4, 1+end/4:end-end/4) = true;

target = target(roi);
trial = trial(roi);

f = sqrt(mean((abs(target(:)).^2 - abs(trial(:)).^2).^2));

end
