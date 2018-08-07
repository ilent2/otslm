function [target, trial] = roiAll(target, trial, varargin)
% ROIALL objective ROI for all points
%
% [target, trial] = ROIALL(target, trial, ...)
% signature for otslm.iter.objectives.roi* functions
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% TODO: Should these ROI functions be replaced by classes?
%     Probably, since we are mixing method args with hyper-args
% TODO: Should the objective functions be replaced by classes?
%     Same reasoning as above

p = inputParser;
p.parse(varargin{:});

% Nothing to do
