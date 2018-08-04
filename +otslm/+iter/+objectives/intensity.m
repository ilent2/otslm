function f = intensity(target, trial, varargin)
% INTENSITY objective function to optimise for intensity
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

roi = zeros(size(target), 'logical');
roi(1+end/4:end-end/4, 1+end/4:end-end/4) = true;

target = target(roi);
trial = trial(roi);

f = -1 * mean(abs(trial(:)).^2 .* abs(target(:)).^2);

end
