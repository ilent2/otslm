function [target, trial] = roiMask(target, trial, mask, varargin)
% ROIMASK applies a mask as the region of interest selector
%
% [target, trial] = ROIAPERTURE(target, trial, mask, ...)
% signature for otslm.iter.objectives.roi* functions with mask argument.
% The mask is the roi this function applies.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.parse(varargin{:});

% Apply mask to target and trial
target = target(mask);
trial = trial(mask);

