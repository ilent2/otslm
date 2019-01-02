function beam = hologram2bsc(pattern, varargin)
% HOLOGRAM2BSC convert pattern to beam shape coefficients
%
% beam = hologram2bsc(pattern, ...) converts the pattern to a BSC beam.
% If pattern is real, assumes a phase pattern, else assumes complex amplitude.
%
% Optional named parameters:
%   incident   pattern    Uses the incident illumination
%   amplitude  amplitude  Specifies the amplitude of the pattern
%   Nmax       num        The VSWF truncation number
%   polarisation [x,y]    Polarisation of the VSWF beam
%   index_medium num      Refractive index of medium
%   NA           num      Numerical aperture of objective
%   beamData     beam     Pass an existing Paraxial beam to reuse
%     the pre-computed special functions.
%   keep_coefficient_matrix  bool  Calculate the inverse coefficient
%     matrix and store it with the beam.  This is slower for a single
%     calculation but can be faster for repeated calculation. Default: false.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('incident', []);
p.addParameter('amplitude', []);
p.addParameter('Nmax', 20);
p.addParameter('polarisation', [1, 1i]);
p.addParameter('index_medium', 1.33);
p.addParameter('NA', 1.02);
p.addParameter('beamData', []);
p.addParameter('keep_coefficient_matrix', false);
p.parse(varargin{:});

% Create a beam object from the inputs
pattern = otslm.tools.make_beam(pattern, ...
    'incident', p.Results.incident, ...
    'amplitude', p.Results.amplitude);

% Calculate beam using OTT
beam = ott.BscPmParaxial(-p.Results.NA, pattern, ...
    'index_medium', p.Results.index_medium, ...
    'polarisation', p.Results.polarisation, ...
    'Nmax', p.Results.Nmax, ...
    'beamData', p.Results.beamData, ...
    'keep_coefficient_matrix', p.Results.keep_coefficient_matrix);

