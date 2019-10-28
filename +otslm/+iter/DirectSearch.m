classdef DirectSearch < otslm.iter.IterBase
% Optimiser to search through each pixel value to optimise hologram
% Inherits from :class:`IterBase`.
%
% This method randomly selects a pixel in the pattern and then tries
% every available level.  The pixel value kept is the pixel value whic
% gives the best fitness.
%
% The algorithm is described in
% Di Leonardo, et al., Opt. Express 15, 1913-1922 (2007)
%
% Methods
%   - run()     --  Run the iterative method
%
% Properties
%   - levels    --  Discrete levels that will be search in optimisation
%
% Inherited properties
%   - guess     --  Best guess at hologram pattern
%   - target    --  Target pattern the method tries to approximate
%   - vismethod --  Method used to do the visualisation
%   - invmethod --  Method used to calculate initial guess/inverse-visualisation
%   - objective --  Objective function used to evaluate fitness
%   - fitness   --  Fitness evaluated after every iteration
%
% See also DirectSearch and :class:`SimulatedAnnealing`.

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  % TODO: Adapt implementation for amplitude patterns

  properties
    levels      % Discrete levels that will be search in optimisation
  end

  methods
    function mtd = DirectSearch(target, varargin)
      % Construct a new instance of the DirectSearch iterative method
      %
      % Usage
      %   mtd = DirectSearch(target, ...) attempts to produce the target
      %   using the Direct Search algorithm.
      %
      % Optional named arguments:
      %   - levels    num -- Number of discrete phase levels or array of
      %     levels between -pi and pi.  Default: 256.
      %
      %   - guess     im  -- Initial guess at complex amplitude pattern.
      %     If not image is supplied, a guess is created using invmethod.
      %
      %   - vismethod fcn -- Function to calculate far-field.  Takes one
      %     argument: the complex amplitude near-field.
      %     Default: @otslm.tools.prop.FftForward.simpleProp.evaluate
      %
      %   - invmethod fcn -- Function to calculate near-field.  Takes one
      %     argument: the complex amplitude far-field.
      %     Default: @otslm.tools.prop.FftInverse.simpleProp.evaluate
      %
      %   - objective fcn -- Objective function to measure fitness.
      %     Default: @otslm.iter.objectives.FlatIntensity

      % Parse inputs
      p = inputParser;
      p.KeepUnmatched = true;
      p.addParameter('levels', 256);
      p.parse(varargin{:});

      % Call base class for most handling
      unmatched = [fieldnames(p.Unmatched).'; struct2cell(p.Unmatched).'];
      mtd = mtd@otslm.iter.IterBase(target, unmatched{:});

      % Store levels and create array if needed
      mtd.levels = p.Results.levels;
      if isscalar(mtd.levels)
        mtd.levels = linspace(-pi, pi, mtd.levels+1);
        mtd.levels = mtd.levels(1:end-1);
      end

      % Convert the guess to the discrete levels
      new_phase = interp1([mtd.levels, pi], [mtd.levels, mtd.levels(1)], ...
          mtd.phase, 'nearest');
      mtd.guess = exp(1i*new_phase);
    end

    function result = iteration(mtd)
      % Implementation of the Direct Search algorithm

      % Pick a random pixel location
      loc = randi(numel(mtd.guess), 1);

      % Try all values for this pixel
      pixelFitness = zeros(numel(mtd.levels), 1);
      pixelGuess = mtd.phase;
      for jj = 1:length(pixelFitness)

        % Change the pixel value
        pixelGuess(loc) = mtd.levels(jj);

        % Evaluate the fitness of this guess
        pixelFitness(jj) = mtd.evaluateFitness(exp(1i*pixelGuess));

      end

      % Update the guess
      if strcmpi(mtd.objective.type, 'min')
        [bestFittness, idx] = min(pixelFitness);
      elseif strcmpi(mtd.objective.type, 'max')
        [bestFittness, idx] = max(pixelFitness);
      else
        error('Unknown objective type');
      end
      mtd.guess(loc) = exp(1i*mtd.levels(idx));
      mtd.fitness(end+1) = bestFittness;

      % Return the latest guess
      if nargout > 0
        result = mtd.guess;
      end
    end
  end
end
