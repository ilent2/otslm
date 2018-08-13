function [pattern, beam, coeffs] = bsc(sz, target, varargin)
% BSC optimise beam in beam shape coefficient basis
%
% [pattern, beam, coeffs] = bsc(target, ...) attempt to produce
% target using a phase pattern.  Returns the phase pattern matched
% to the beam (bsc) and optimised basis weighting coefficients.
%
% Optional named parameters:
%   'incident'  pattern  Incident illumination on SLM
%   'roi'       func     Region to optimise (default: roiAll)
%   'basis'     str      BSC basis to optimise in (default: vswf_lg)
%   'basis_size' num     Number of basis functions to use
%   'polarisation' [x y] Polarisation of the basis functions
%   'wavelength' num     Wavelength in medium [m]
%   'speed'     num      Speed in medium [m/s]
%   'NA'        num      Numberical aperture of objective
%   'pixel_size' num     Size of pixels in target [m]
%   'method'    str      Optimisation method to use
%   'radius'    num      Radius for hologram unwrapping (default: 1.0)
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('incident', ones(size(sz)));
p.addParameter('objective', @otslm.iter.objectives.bowman2017cost);
p.addParameter('basis', 'vswf_lg');     % Not used yet
p.addParameter('basis_size', 40);
p.addParameter('polarisation', [1 1i]);
p.addParameter('radius', 1.0);
p.addParameter('guess', []);

p.addParameter('wavelength0', 1064e-9);
p.addParameter('speed0', 3.0e8);
p.addParameter('index_medium', 1.0);

p.addParameter('NA', 1.2);
p.addParameter('pixel_size', 2.0e-6/sqrt(sum((size(target)/2).^2)));
p.addParameter('method', 'cgs');
p.addParameter('verbose', false);
p.parse(varargin{:});

% Calculate Nmax for basis functions
rtarget = sqrt(sum((size(target)/2).^2)) * p.Results.pixel_size;
Nmax = ott.utils.ka2nmax(p.Results.index_medium*(2*pi)*rtarget ...
    ./ p.Results.wavelength0);
if Nmax > 200
  warning(['Nmax = ' num2str(Nmax)]);
end

if p.Results.verbose
  disp(['Using Nmax = ' num2str(Nmax)]);
  disp('Calculating basis functions');
  tic
end

% Calculate basis functions 
kk = 1;
for ii = 1:p.Results.basis_size
  
  if p.Results.verbose
    disp(['... iteration ' num2str(kk)]);
  end
  
  for jj = 1:p.Results.basis_size-ii+1
    try
      beams(kk) = ott.BscPmGauss('lg', [ ii-1, jj-1 ], ...
          'polarisation', p.Results.polarisation, 'NA', p.Results.NA, ...
          'wavelength0', p.Results.wavelength0, ...
          'index_medium', p.Results.index_medium, ...
          'omega', 2*pi*p.Results.speed0/p.Results.wavelength0, ...
          'Nmax', Nmax);
      kk = kk + 1;
    catch ME
      if ~strcmp(ME.identifier, 'OTT:BSC:make_beam_vector:no_modes')
        rethrow(ME);
      end
    end
  end
end

if p.Results.verbose
  disp(['... took ', num2str(toc), ' seconds']);
  disp(['Generated ', num2str(length(beams)) ', out of ', ...
    num2str(p.Results.basis_size*(p.Results.basis_size+1)/2), ' beams']);
  disp('Calculating fields for basis functions');
  tic
  lastTic = toc();
end

% Calculate locations for target
xrange = (1:size(target, 2)) - 0.5 - size(target, 2)/2;
yrange = (1:size(target, 1)) - 0.5 - size(target, 1)/2;
zrange = (1:size(target, 3)) - 0.5 - size(target, 3)/2;
[xx, yy, zz] = meshgrid(xrange, yrange, zrange);
xyz = [xx(:).'; yy(:).'; zz(:).'].*p.Results.pixel_size;

% Calculate the fields for these beams
% TODO: This could probably be optimised by calculating the
%   spherical wave functions for all beams in advance
modes = zeros(3*numel(target), length(beams));
for ii = 1:length(beams)
  
  if p.Results.verbose && toc()-lastTic > 10
    disp(['... mode ' num2str(ii)]);
    lastTic = toc();
  end
  
  E = beams(ii).emFieldXyz(xyz);
  modes(:, ii) = E(:);
end

if p.Results.verbose
  disp(['... took ', num2str(toc), ' seconds']);
  disp('Calculating target in basis functions');
  tic
end

% Scale the incident and target patterns for the optimisation

% TODO: We really should make the objective a object with a roi method
%   since we need it to normalize the beam power
Ttotal = sum(abs(target(:)).^2);

% Hmm, this seems inefficient, perhaps just set the beam power?
S = 100;
Mtotals = zeros(length(beams), 1);
for ii = 1:length(beams)
  Mtotals(ii) = sum(abs(modes(:, ii)).^2);
  modes(:, ii) = modes(:, ii) .* S ./ Mtotals(ii).^0.5;
  beams(ii).power = beams(ii).power * S ./ Mtotals(ii).^0.5;
  Mtotals(ii) = sum(abs(modes(:, ii)).^2);
end

target = target .* (Mtotals(1) ./ Ttotal).^0.5;

% Calculate the initial guess for the coefficients
if ischar(p.Results.guess)
  guessType = 'rand';
  switch guessType
    case 'xypol'

      % Use the X/Y field amplitudes
      smodes = zeros(numel(target), length(beams));
      for ii = 1:length(beams)
        smodes(:, ii) = modes(1:3:end, ii)*conj(p.Results.polarisation(1)) ...
            + modes(2:3:end, ii)*conj(p.Results.polarisation(2));
      end
      guess = smodes \ target(:);

    case 'zpol'
      % Use the Z field amplitudes
      guess = modes(3:3:end, :) \ target(:);
    case 'xpol'
      % Use the X field amplitudes
      guess = modes(1:3:end, :) \ target(:);
    case 'ypol'
      % Use the Y field amplitudes
      guess = modes(2:3:end, :) \ target(:);

    case 'rand'
      % Use a random guess
      guess = complex(2*rand(size(beams)) - 1, 2*rand(size(beams)) - 1).';
    otherwise
      error('Unknown guess type option');
  end
else
  guess = p.Results.guess(:);
end

% Generate the optimisation function
optfun = @(x) p.Results.objective(target, ...
  reshape(sqrt(sum(abs(reshape(modes * x, [3, size(modes, 1)/3])).^2, 1)), size(target)));

% Attempt to optimise using fminsearch
% optopts = optimset('PlotFcns', @optimplotfval);
% coeffs = fminsearch(optfun, guess, optopts);

% Attempt to optimise using fminunc
optopts = optimset('PlotFcns', @optimplotfval);
coeffs = fminunc(optfun, guess, optopts);

% % Calculate the decomposition of the target in the basis
% optopts = optimoptions(@fsolve,'Display','iter','FunctionTolerance',1e-10,...
%   'Algorithm', 'levenberg-marquardt', 'MaxFunctionEvaluations', 80000, ...
%   'ScaleProblem', 'jacobian');
% coeffs = fsolve(optfun, guess, optopts);

% Calculate the farfield amplitude of the beam
beam = beams(1)*coeffs(1);
for ii = 2:length(beams)
  beam = beam + beams(ii)*coeffs(ii);
end

if p.Results.verbose
  disp(['... took ', num2str(toc), ' seconds']);
  disp('Calculating phase pattern');
end

% Calculate hologram from bsc for incident beam
pattern = otslm.tools.bsc2hologram(sz, beam, ...
    'incident', p.Results.incident, 'polarisation', p.Results.polarisation, ...
    'radius', p.Results.radius);

