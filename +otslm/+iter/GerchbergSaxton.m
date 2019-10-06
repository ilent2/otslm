classdef GerchbergSaxton < otslm.iter.IterBase
% Implementation of Gerchberg-Saxton and Adaptive-Adaptive algorithms
%
% Methods
%   run()         Run the iterative method
%
% Properties
%   adaptive      Adaptive-adaptive factor (1 for Gerchberg-Saxton)
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
    adaptive      % Adaptive-adaptive factor (1 for Gerchberg-Saxton)
  end
  
  methods (Static)
    function p = inputParser(varargin)
      % Get the inputParser for the GerchbergSaxton constructor
      p = inputParser;
      p.KeepUnmatched = true;
      p.addParameter('adaptive', 1.0);
      p.parse(varargin{:});
    end
  end

  methods
    function mtd = GerchbergSaxton(target, varargin)
      % Construct a new instance of the GerchbergSaxton iterative method
      %
      % mtd = GerchbergSaxton(target, ...) attempts to produce target
      % using the Gerchberg-Saxton algorithm.
      %
      % Optional named arguments:
      %   adaptive  num    Adaptive-Adaptive factor.  Default: 1.0, i.e.
      %     the method is Gerchberg-Saxton.
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
      p = otslm.iter.GerchbergSaxton.inputParser(varargin{:});

      % Call base class for most handling
      unmatched = [fieldnames(p.Unmatched).'; struct2cell(p.Unmatched).'];
      mtd = mtd@otslm.iter.IterBase(target, unmatched{:});

      % Store adaptive-adaptive factor
      mtd.adaptive = p.Results.adaptive;

    end

    function result = iteration(mtd)
      % Implementation of the Gerchberg-Saxton algorithm

      % Calculate generated pattern from guess
      B = mtd.guess;
      output = mtd.vismethod(B);

      % Do adaptive-adaptive step
      targetAmplitude = mtd.adaptive.*abs(mtd.target) ...
          + (1 - mtd.adaptive).*abs(output);

      % Calculate new guess
      D = targetAmplitude .* exp(1i*angle(output));
      mtd.guess = exp(1i.*angle(mtd.invmethod(D)));

      % Return the latest guess
      if nargout > 0
        result = mtd.guess;
      end

      % Evaluate the fitness (optional for GS)
      if ~isempty(mtd.objective)
        mtd.fitness(end+1) = mtd.evaluateFitness();
      end

    end
  end

end
