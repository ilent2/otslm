function f = goorden2014fidelity(target, trial, varargin)
% GOORDEN2014FIDELITY error calculated from fidelity function
%   Fidelity is defined in Goorden, et al. 2014 as
%
%  F = |conj(target) * trial|^2
%
% Error is 1 - F.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.parse(varargin{:});

% Apply mask to target and trial
roi = zeros(size(target), 'logical');
roi(1+end/4:end-end/4, 1+end/4:end-end/4) = true;

target = target(roi);
trial = trial(roi);

% Calculate fidelity
F = abs(sum(conj(target(:)).*trial(:))).^2;

f = 1.0 - F;

