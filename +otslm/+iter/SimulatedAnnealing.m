classdef SimulatedAnnealing < otslm.iter.IterBase
% Optimise the pattern using simulated annealing
%
% Methods
%   run()         Run the iterative method
%
% Properties
%   levels         Discrete levels that will be search in optimisation
%   temperature    Current temperature of the system
%   maxTemperature Scaling factor for new pattern guesses
%   temperatureFcn Function used to calculate temperature in iteration
%   lastFitness    The fitness associated with the current guess
%
%   guess         Best guess at hologram pattern
%   target        Target pattern the method tries to approximate
%   vismethod     Method used to do the visualisation
%   invmethod     Method used to calculate initial guess/inverse-visualisation
%   objective     Objective function used to evaluate fitness
%   fitness       Fitness evaluated after every iteration
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties
    levels      % Discrete levels that will be search in optimisation
    lastFitness % The fitness associated with the current guess
    temperature % Current temperature of the system
    maxTemperature % Scaling factor for new pattern guesses
    temperatureFcn % Function used to calculate temperature in iteration
  end

  methods (Static)

    function fcn = simpleTemperatureFcn(scale, decay)
      % Returns a exponentially decaying temperature function
      %
      % fcn = simpleTemperatureFcn(scale, decay) creates a exponentially
      % decaying temperature function.  Scale is the initial temperature
      % and decay is the exponential decay rate.

      fcn = @(ii, ~) scale*exp(-ii/decay);
    end

  end

  methods
    function mtd = SimulatedAnnealing(target, varargin)
      % Construct a new instance of the SimulatedAnnealing iterative method
      %
      % mtd = SimulatedAnnealing(target, ...) attempts to produce the
      % target using the Simulated Annealing algorithm.
      %
      % Optional named arguments:
      %   levels    num    Number of discrete levels or array of
      %     levels between -pi and pi.  Default: 256.
      %   temperature num  Initial temperature of the solver.
      %
      %   guess     im     Initial guess at complex amplitude pattern.
      %     If not image is supplied, a guess is created using invmethod.
      %
      %   vismethod fcn    Function to calculate far-field.  Takes one
      %     argument: the complex amplitude near-field.
      %     Default: @otslm.tools.prop.FftForward.simpleProp.evaluate
      %
      %   invmethod fcn    Function to calculate near-field.  Takes one
      %     argument: the complex amplitude far-field.
      %     Default: @otslm.tools.prop.FftInverse.simpleProp.evaluate
      %
      %   objective fcn    Objective function to measure fitness.
      %     Default: @otslm.iter.objectives.FlatIntensity

      % Parse inputs
      p = inputParser;
      p.KeepUnmatched = true;
      p.addParameter('levels', 256);
      p.addParameter('temperature', 1e3);
      p.addParameter('maxTemperature', 1e4);
      p.addParameter('temperatureFcn', []);
      p.parse(varargin{:});

      % Call base class for most handling
      unmatched = [fieldnames(p.Unmatched).'; struct2cell(p.Unmatched).'];
      mtd = mtd@otslm.iter.IterBase(target, unmatched{:});

      % Store parameters
      mtd.temperature = p.Results.temperature;
      mtd.maxTemperature = p.Results.maxTemperature;
      mtd.temperatureFcn = p.Results.temperatureFcn;

      % Handle default value for temperature function
      if isempty(mtd.temperatureFcn)
        mtd.temperatureFcn = mtd.simpleTemperatureFcn(mtd.temperature, 1e1);
      end

      % Store levels and create array if needed
      mtd.levels = p.Results.levels;
      if isscalar(mtd.levels)
        mtd.levels = linspace(-pi, pi, mtd.levels+1);
        mtd.levels = mtd.levels(1:end-1);
      end

      % Convert the guess to the discrete levels
      mtd.guess = exp(1i*mtd.makeDiscrete(mtd.phase));

      % Calculate original fitness
      mtd.fitness(1) = mtd.evaluateFitness();
      mtd.lastFitness = mtd.fitness(1);
    end

    function guess = makeDiscrete(mtd, guess)
      % Make the guess discrete
      if ~isempty(mtd.levels)
        guess = angle(exp(1i*guess));
        guess = interp1([mtd.levels, pi], [mtd.levels, mtd.levels(1)], ...
            guess, 'nearest');
      end
    end

    function result = iteration(mtd)
      % Implementation of simulated annealing

      % Calculate the temperature
      mtd.temperature = mtd.temperatureFcn(length(mtd.fitness), mtd);

      % Calculate the new noise scale based on temperature
      scale = mtd.temperature./mtd.maxTemperature;

      % Generate new guess
      newGuess = mtd.phase + randn(size(mtd.guess))*scale;

      % Convert new Guess to discrete levels
      newGuess = mtd.makeDiscrete(newGuess);

      % Evaluate the fitness of the new guess
      U_newGuess = exp(1i*newGuess);
      mtd.fitness(end+1) = mtd.evaluateFitness(U_newGuess);

      % Determine if this trial is satisfactory to keep
      if strcmpi(mtd.objective.type, 'min')
        if mtd.fitness(end) <= mtd.lastFitness ...
            || exp(-(mtd.fitness(end)-mtd.lastFitness)/mtd.temperature) > rand()
          mtd.guess = U_newGuess;
          mtd.lastFitness = mtd.fitness(end);
        end
      elseif strcmpi(mtd.objective.type, 'max')
        if mtd.fitness(end) >= mtd.lastFitness ...
            || exp((mtd.fitness(end)-mtd.lastFitness)/mtd.temperature) > rand()
          mtd.guess = U_newGuess;
          mtd.lastFitness = mtd.fitness(end);
        end
      else
        error('Unknown objective type');
      end
      
      % Provide the result if requested
      if nargout > 0
        result = mtd.guess;
      end
    end
  end
end
