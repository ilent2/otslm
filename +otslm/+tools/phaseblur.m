function pattern = phaseblur(pattern, varargin)
% PHASEBLUR simulate pixel phase blurring
%
% pattern = phaseblur(pattern, ...) applies Gaussian blur to the pattern.
%
% Optional named arguments:
%   colormap   map    colormap to apply before/after blurring (default: [])
%   invmap     bool   apply inverse colormap at end (default: true)
%   sigma      num    size of the Gaussian kernel
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('colormap', []);
p.addParameter('invmap', true);
p.addParameter('sigma', 1.0);
p.parse(varargin{:});

% Apply colormap
pattern = otslm.tools.colormap(pattern, p.Results.colormap);

% Apply a Gaussian kernel to blur phase
pattern = imgaussfilt(pattern, p.Results.sigma);

% Apply inverse colormap
if p.Results.invmap
  pattern = otslm.tools.colormap(pattern, p.Results.colormap);
end

