function [target, trial] = roiAperture(target, trial, varargin)
% ROIAPERTURE creates a aperture mask in the centre of the space
%
% [target, trial] = ROIAPERTURE(target, trial, ...)
% signature for otslm.iter.objectives.roi* functions
%
% Optional named parameters:
%   'fftshift'    boolean   Apply fftshift to the mask
%   'dimensions'  dims      Dimension argument for otslm.simple.aperture
%   For other optional parameters, see otslm.simple.aperture
%
% The default ROI is a circle with diameter min(size(target))/2
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('fftshift', false);
p.addParameter('dimensions', min(size(target))/4);
p.addParameter('shape', 'circle');
p.addParameter('centre', size(target)/2.0);
p.addParameter('offset', zeros(size(target)));
p.addParameter('aspect', ones(1, numel(size(target))-1));
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
p.parse(varargin{:});

assert(all(size(target) == size(trial)), 'Trial and target must be same size');

% Generate the ROI mask
roi = otslm.simple.aperture(size(target), p.Results.dimensions, ...
    'shape', p.Results.shape, 'centre', p.Results.centre, ...
    'offset', p.Results.offset, 'value', [false, true], ...
    'aspect', p.Results.aspect, 'angle_deg', p.Results.angle_deg, ...
    'angle', p.Results.angle);

% Apply the fftshift if requested
if p.Results.fftshift
  roi = fftshift(roi);
end

% Generate the outputs
target = target(roi);
trial = trial(roi);

