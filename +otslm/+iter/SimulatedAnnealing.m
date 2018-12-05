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
%   guess          Best guess at hologram pattern
%   target         Target pattern the method tries to approximate
%   vismethod      Method used to do the visualisation
%   invmethod      Method used to calculate initial guess/inverse-visualisation
%   visdata        Additional arguments to pass to vismethod
%   invdata        Additional arguments to pass to invmethod
%   objective      Objective function used to evaluate fitness
%   fitness        Fitness evaluated after every iteration
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
    function mtd = SimulatedAnnealing(varargin)
      % Construct a new instance of the SimulatedAnnealing iterative method
      %
      % mtd = SimulatedAnnealing(target, ...) attempts to produce the
      % target using the Simulated Annealing algorithm.
      %
      % Optional named arguments:
      %   guess     im     Initial guess at phase pattern.
      %     Image must be complex amplitude or real phase in range 0 to 2*pi.
      %     If not image is supplied, a guess is created using invmethod.
      %   levels    num    Number of discrete levels or array of
      %     levels between -pi and pi.  Default: 256.
      %   temperature num  Initial temperature of the solver.
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
      p.addParameter('temperature', 1e3);
      p.addParameter('maxTemperature', 1e4);
      p.addParameter('temperatureFcn', []);
      p.addParameter('vismethod', @otslm.iter.IterBase.defaultVisMethod);
      p.addParameter('invmethod', @otslm.iter.IterBase.defaultInvMethod);
      p.addParameter('visdata', {});
      p.addParameter('invdata', {});
      p.addParameter('objective', @otslm.iter.objectives.flatintensity);
      p.addParameter('objective_type', 'min');
      p.parse(varargin{:});

      % Call base class for most handling
      mtd = mtd@otslm.iter.IterBase(p.Results.target, ...
          'guess', p.Results.guess, ...
          'vismethod', p.Results.vismethod, ...
          'invmethod', p.Results.invmethod, ...
          'visdata', p.Results.visdata, ...
          'invdata', p.Results.invdata, ...
          'objective', p.Results.objective, ...
          'objective_type', p.Results.objective_type);

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
      mtd.guess = mtd.makeDiscrete(mtd.guess);

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
      newGuess = mtd.guess + randn(size(mtd.guess))*scale;

      % Convert new Guess to discrete levels
      newGuess = mtd.makeDiscrete(newGuess);

      % Evaluate the fitness of the new guess
      mtd.fitness(end+1) = mtd.evaluateFitness(newGuess);

      % Determine if this trial is satisfactory to keep
      if strcmpi(mtd.objective_type, 'min')
        if mtd.fitness(end) <= mtd.lastFitness ...
            || exp(-(mtd.fitness(end)-mtd.lastFitness)/mtd.temperature) > rand()
          mtd.guess = newGuess;
          mtd.lastFitness = mtd.fitness(end);
        end
      elseif strcmpi(mtd.objective_type, 'max')
        if mtd.fitness(end) >= mtd.lastFitness ...
            || exp((mtd.fitness(end)-mtd.lastFitness)/mtd.temperature) > rand()
          mtd.guess = newGuess;
          mtd.lastFitness = mtd.fitness(end);
        end
      end
      
      % Provide the result if requested
      if nargout ~= 0
        result = mtd.guess;
      end
    end
  end
end
