classdef IterCombine < otslm.iter.IterBase
% Base class for iterative combination algorithms.
% Inherits from :class:`IterBase`.
%
% Iterative methods that inherit from this class attempt to combine
% a set of SLM phase patterns :math:`\phi_m` into a single phase
% pattern which generates a far-field phase pattern approximating the
% combination of each input phase pattern.
%
% The target field is a optional and is only used for estimating
% fitness of the generated pattern.
%
% Methods (inherited)
%   - run()         -- Run the iterative method
%   - showFitness() -- Show the fitness graph
%
% Properties
%   - components (real: 0, 2*pi) -- NxMxD matrix of D patterns to be combined.
%
% Properties (inherited)
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
% Abstract methods
%   - iteration()  --   run a single iteration of the method

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties
    components    % NxMxD matrix of D patterns to be combined.
  end

  methods
    function mtd = IterCombine(components, varargin)
      % Constructor for iterative combination algorithms (abstract) base class
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
      %     Optional: only used for fitness evaluation.
      %     Default: @otslm.tools.prop.FftForward.simpleProp.propagate
      %
      %   - invmethod fcn    Function to calculate near-field.  Takes one
      %     argument: the complex amplitude far-field.
      %     Optional: not used.
      %     Default: @otslm.tools.prop.FftInverse.simpleProp.propagate
      %
      %   - objective fcn    Objective function to measure fitness.
      %     Default: @otslm.iter.objectives.FlatIntensity

      p = inputParser;
      p.KeepUnmatched = true;
      p.addParameter('vismethod', []);
      p.addParameter('target', []);
      p.addParameter('guess', []);
      p.addParameter('gpuArray', []);
      p.parse(varargin{:});

      % Handle default gpuArray argument
      useGpuArray = p.Results.gpuArray;
      if isempty(useGpuArray)
        useGpuArray = isa(components, 'gpuArray') ...
            || isa(p.Results.guess, 'gpuArray') ...
            || isa(p.Results.target, 'gpuArray');
      end

      % Calculate guess
      guess = p.Results.guess;
      if isempty(guess)
        guess = otslm.tools.combine(num2cell(components, [1, 2]), ...
            'method', 'rsuper');
        guess = exp(2*pi*1i*guess);
      end

      % Handle default visualisation method (needed for default target)
      vismethod = p.Results.vismethod;
      if isempty(vismethod)
        prop = otslm.tools.prop.FftForward.simpleProp(guess, ...
            'gpuArray', useGpuArray);
        vismethod = @prop.propagate;
      end

      % Set the actual target
      target = p.Results.target;
      if isempty(target)
        target = otslm.tools.combine(num2cell(exp(1i*components), [1, 2]), ...
            'method', 'farfield', 'vismethod', vismethod);
      end

      % Call base class for most handling
      unmatched = [fieldnames(p.Unmatched).'; struct2cell(p.Unmatched).'];
      mtd = mtd@otslm.iter.IterBase(target, unmatched{:}, ...
          'guess', guess, 'gpuArray', useGpuArray, 'vismethod', vismethod);

      mtd.components = components;

      % Evaluate first guess (optional)
      if ~isempty(mtd.objective)
        mtd.fitness(end+1) = mtd.evaluateFitness();
      end
    end
  end
end
