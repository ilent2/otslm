classdef DirectSearch < otslm.iter.IterBase
% search through each pixel value to optimise hologram
%
% The algorithm is described in
% Di Leonardo, et al., Opt. Express 15, 1913-1922 (2007)
%
% Properties
%   levels        Discrete levels that will be search in optimisation
%   guess         Best guess at hologram pattern
%   target        Target pattern the method tries to approximate
%   vismethod     Method used to do the visualisation
%   invmethod     Method used to calculate initial guess/inverse-visualisation
%   visdata       Additional arguments to pass to vismethod
%   invdata       Additional arguments to pass to invmethod
%   objective     Objective function used to evaluate fitness
%   fitness       Fitness evaluated after every iteration
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties
    levels      % Discrete levels that will be search in optimisation
  end

  methods
    function mtd = DirectSearch(varargin)
      % Construct a new instance of the DirectSearch iterative method
      %
      % mtd = DirectSearch(target, ...) attempts to produce the target
      % using the Direct Search algorithm.
      %
      % Optional named arguments:
      %   guess     im     Initial guess at phase pattern.
      %     Image must be complex amplitude or real phase in range 0 to 2*pi.
      %     If not image is supplied, a guess is created using invmethod.
      %   levels    num    Number of discrete levels or array of
      %     levels between -pi and pi.  Default: 256.
      %   objective fcn    Objective function to measure fitness.
      %   vismethod fcn    Function to calculate far-field.  Takes one
      %     argument: the complex amplitude near-field.
      %   invmethod fcn    Function to calculate near-field.  Takes one
      %     argument: the complex amplitude far-field.

      % Parse inputs
      p = inputParser;
      p.addRequired('target');
      p.addParameter('guess', []);
      p.addParameter('levels', 256);
      p.addParameter('vismethod', @otslm.iter.IterBase.defaultVisMethod);
      p.addParameter('invmethod', @otslm.iter.IterBase.defaultInvMethod);
      p.addParameter('visdata', {});
      p.addParameter('invdata', {});
      p.addParameter('objective', @otslm.iter.objectives.flatintensity);
      p.parse(varargin{:});

      % Call base class for most handling
      mtd = mtd@otslm.iter.IterBase(p.Results.target, ...
          'guess', p.Results.guess, ...
          'vismethod', p.Results.vismethod, ...
          'invmethod', p.Results.invmethod, ...
          'visdata', p.Results.visdata, ...
          'invdata', p.Results.invdata, ...
          'objective', p.Results.objective);

      % Store levels and create array if needed
      mtd.levels = p.Results.levels;
      if isscalar(mtd.levels)
        mtd.levels = linspace(-pi, pi, mtd.levels+1);
        mtd.levels = mtd.levels(1:end-1);
      end

      % Convert the guess to the discrete levels
      mtd.guess = angle(exp(1i*mtd.guess));
      mtd.guess = interp1([mtd.levels, pi], [mtd.levels, mtd.levels(1)], ...
          mtd.guess, 'nearest');
    end

    function result = iteration(mtd)
      % Implementation of the Direct Search algorithm

      % Pick a random pixel location
      loc = randi(numel(mtd.guess), 1);

      % Try all values for this pixel
      pixelFitness = zeros(numel(mtd.levels), 1);
      pixelGuess = mtd.guess;
      for jj = 1:length(pixelFitness)

        % Change the pixel value
        pixelGuess(loc) = mtd.levels(jj);

        % Evaluate the fitness of this guess
        pixelFitness(jj) = mtd.evaluateFitness(pixelGuess);

      end

      % Update the guess
      [bestFittness, idx] = min(pixelFitness);
      mtd.guess(loc) = mtd.levels(idx);
      mtd.fitness(end+1) = bestFittness;

      % Return the latest guess
      result = mtd.guess;
    end
  end
end
