function [target, trial] = roiAperture(target, trial, varargin)
% ROIAPERTURE creates a aperture mask in the centre of the space
%
% [target, trial] = ROIAPERTURE(target, trial, ...)
% signature for otslm.iter.objectives.roi* functions
%
% Optional named parameters:
%   'fftshift'    boolean   Apply fftshift to the mask
%   For other optional parameters, see otslm.simple.aperture
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('fftshift', false);
p.addParameter('type', 'circle');
p.addParameter('centre', size(target)/2.0);
p.addParameter('offset', zeros(size(target)));
p.addParameter('aspect', ones(1, numel(size(target))-1);
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
p.parse(varargin{:});

% Generate the ROI mask
roi = otslm.simple.aperture(size(target), p.Results.dimensions, ...
    'type', p.Results.type, 'centre', p.Results.centre, ...
    'offset', p.Results.offset, 'values', [false, true], ...
    'aspect', p.Results.aspect, 'angle_deg', p.Results.angle_deg, ...
    'angle', p.Results.angle);

% Apply the fftshift if requested
if p.Results.fftshift
  roi = fftshift(roi);
end

% Generate the outputs
target = target(roi);
trial = trial(roi);

