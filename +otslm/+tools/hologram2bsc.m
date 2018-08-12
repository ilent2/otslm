function beam = hologram2bsc(pattern, varargin)
% HOLOGRAM2BSC convert pattern to beam shape coefficients
%
% beam = hologram2bsc(pattern, ...) converts the pattern to a BSC beam.
% If pattern is real, assumes a phase pattern, else assumes complex amplitude.
%
% Optional named parameters:
%   'incident'   pattern    Uses the incident illumination
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('incident', ones(size(pattern)));
p.addParameter('Nmax', 20);
p.addParameter('polarisation', [1, 1i]);
p.addParameter('index_medium', 1.33);
p.addParameter('NA', 1.02);
p.parse(varargin{:});

% Convert pattern to complex amplitude
if isreal(pattern)
  pattern = exp(1i*pattern);
end

% Apply incident beam amplitude to pattern
pattern = pattern .* p.Results.incident;

% Calculate beam using OTT
beam = ott.BscPmParaxial(-p.Results.NA, pattern, ...
    'index_medium', p.Results.index_medium, ...
    'polarisation', p.Results.polarisation, ...
    'Nmax', p.Results.Nmax);

