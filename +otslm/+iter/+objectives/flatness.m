function f = flatness(target, trial, varargin)
% FLATNESS objective function to optimise for flatness
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

roi = zeros(size(target), 'logical');
roi(1+end/4:end-end/4, 1+end/4:end-end/4) = true;

target = target(roi);
trial = trial(roi);

T = abs(target(:)).^2;
I = abs(trial(:)).^2 .* T;
mI = mean(I);

f = sum(T) .* sqrt( mean(( I - mI ).^2) ) ./ mI;

end
