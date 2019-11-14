classdef CombineGerchbergSaxton < otslm.iter.IterCombine
% Implementation of Gerchberg-Saxton type combination algorithms.
% Inherits from :class:`IterCombine`.
%
% This includes Gerchberg-Saxton, Adaptive-Adaptive and weighted
% GerchbergSaxton algorithms.
%
% For details about these algorithms, see R. Di Leonardo, et al.,
% Opt. Express 15 (4) (2007) 1913-1922.
% https://doi.org/10.1364/OE.15.001913
%
% Properties
%   - adaptive (numeric) -- adaptive-adaptive factor.
%   - weighted (logical) -- if the method is weighted Gerchberg-Saxton.
%
% Methods (inherited)
%   - run()         -- Run the iterative method
%   - showFitness() -- Show the fitness graph
%
% Properties (inherited)
%   - components (real: 0, 2*pi) -- NxMxD matrix of D patterns to be combined.
%
%   - guess      -- Best guess at hologram pattern (complex)
%   - target     -- Target pattern for estimating fitness (complex, optional)
%   - vismethod  -- Method used to do the visualisation
%   - invmethod  -- Method used to calculate initial guess/inverse-visualisation
%
%   - phase      -- Phase of the best guess (real: 0, 2*pi)
%   - amplitude  -- Amplitude of the best guess (real)
%
%   - objective  -- Objective function used to evaluate fitness or []
%   - fitness    -- Fitness evaluated after every iteration or []
%
% See also CombineGerchbergSaxton and :class:`GerchbergSaxton`.

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% TODO: Extend this implementation to amplitude-only devices

  properties
    adaptive    % Adaptive-adaptive factor (default: 1.0)
    weighted    % If the method is weighted Gerchberg-Saxton (default: false)

    weights     % Current weights for weighted GS
  end

  methods
    function mtd = CombineGerchbergSaxton(components, varargin)
      % Construct a new Gerchberg-Saxton combination iterative method.
      %
      % Usage
      %   mtd = IterCombine(components, ...)
      %
      % Parameters
      %   - components (real: 0, 2*pi) -- NxMxD array of D phase patterns
      %     to be combined.  Phase patterns should have range [0, 2*pi] or
      %     equivalent.
      %
      % Optional named arguments
      %   - adaptive  num    Adaptive-Adaptive factor.  Default: 1.0, i.e.
      %     the method is Gerchberg-Saxton.
      %
      %   - weighted (logical) -- If the method should use weighted
      %     Gerchberg-Saxton.  Default: false.
      %
      %   - target (complex) -- approximate pattern for the target.
      %     This is only used for estimating the current fitness.
      %     Default: ``otslm.tools.combine(components, 'method', 'farfield')``.
      %
      %   - guess (complex)  -- Initial guess at combination of patterns.
      %     Default: ``exp(2*pi*1i*random_super)`` where
      %     ``random_super = tools.combine(components, 'method', 'rsuper')``
      %
      %   - vismethod fcn    Function to calculate far-field.  Takes one
      %     argument: the complex amplitude near-field.
      %     Optional, only used for fitness evaluation.
      %     Default: @otslm.tools.prop.FftForward.simpleProp.propagate
      %
      %   - invmethod fcn    Function to calculate near-field.  Takes one
      %     argument: the complex amplitude far-field.
      %     Optional, not used.
      %     Default: @otslm.tools.prop.FftInverse.simpleProp.propagate
      %
      %   - objective fcn    Objective function to measure fitness.
      %     Default: @otslm.iter.objectives.FlatIntensity

      % Parse inputs
      p = inputParser;
      p.KeepUnmatched = true;
      p.addParameter('adaptive', 1.0);
      p.addParameter('weighted', false);
      p.parse(varargin{:});

      % Call base class for most handling
      unmatched = [fieldnames(p.Unmatched).'; struct2cell(p.Unmatched).'];
      mtd = mtd@otslm.iter.IterCombine(components, unmatched{:});

      % Store adaptive-adaptive factor and weighted toggle
      mtd.adaptive = p.Results.adaptive;
      mtd.weighted = p.Results.weighted;
      mtd.weights = ones(1, 1, size(mtd.components, 3));
    end

    function result = iteration(mtd)
      % Implement the Gerchberg-Saxton type algorithms

      % Calculate Vm of current guess
      Vm = sum(sum(exp(1i*(angle(mtd.guess) - mtd.components)), 2), 1);

      % Only update weights if weighted Gerchberg-Saxton
      if mtd.weighted
        mtd.weights = mtd.weights .* mean(abs(Vm)) ./ abs(Vm);
      end

      % Calculate adaptive-adaptive component
      % Our adaptive factor = 1 - Roberto Di Leonardo's 2006 factor
      adaptive = mtd.adaptive + (1-mtd.adaptive) ./ abs(Vm);

      % Calculate new guess
      % Weights should be all ones unless weighted=true
      mtd.guess = sum(exp(1i*mtd.components) ...
          .* mtd.weights .* Vm ./ abs(Vm) .* adaptive, 3);

      % Return latest guess
      if nargout > 0
        result = mtd.guess;
      end

      % Simulate the far-field and evaluate the fitness (optional)
      if ~isempty(mtd.objective)
        mtd.fitness(end+1) = mtd.evaluateFitness();
      end
    end

    function set.adaptive(mtd, val)
      % Check types
      assert(isnumeric(val) && isscalar(val), 'Value must be numeric scalar');
      mtd.adaptive = val;
    end

    function set.weighted(mtd, val)
      % Check types
      assert(islogical(val) && isscalar(val), 'Value must be logical scalar');
      mtd.weighted = val;
    end
  end
end
