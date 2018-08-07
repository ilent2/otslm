function f = bowman2017cost(target, trial, varargin)
% BOWMAN2017cost cost function used in Bowman et al. 2017 paper.
%
%   C = 10^d * (1.0 - \sum_{nm} sqrt(I_nm T_nm) cos(phi_nm - psi_nm)).^2
%
% Optional named arguments:
%     d     value     hyper-parameter of cost function (default: d = 9).
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('d', 9.0);
p.addParameter('roi', @otslm.iter.objectives.roiAll);
p.parse(varargin{:});

% Apply mask to target and trial
[target, trial] = p.Results.roi(target, trial);

% Calculate the target intensity and amplitude
phi = angle(target);
T = abs(target).^2;

% Calculate the current intensity and amplitude
psi = angle(trial);
I = abs(trial).^2;

% Calculate cost
f = (1.0 - sum(sqrt(T(:).*I(:)) .* cos(psi(:) - phi(:)))).^2;

