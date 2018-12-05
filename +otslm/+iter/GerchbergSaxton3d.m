classdef GerchbergSaxton3d < otslm.iter.IterBase3d
% Implementation of 3-D Gerchberg-Saxton and Adaptive-Adaptive algorithms
%
% This algorithm attempts to recreate the target volume using
% the 3-D analog of the Gerchberg-Saxton algorithm.
%
% See Hao Chen et al 2013 J. Opt. 15 035401
% and Graeme Whyte and Johannes Courtial 2005 New J. Phys. 7 117
%
% Methods
%   run()         Run the iterative method
%
% Properties
%   adaptive      Adaptive-adaptive factor (1 for Gerchberg-Saxton)
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
    adaptive      % Adaptive-adaptive factor (1 for Gerchberg-Saxton)
  end

  methods
    function mtd = GerchbergSaxton3d(varargin)
      % Construct a new instance of the GerchbergSaxton3d iterative method
      %
      % mtd = GerchbergSaxton3d(target, ...) attempts to produce target
      % using the Gerchberg-Saxton algorithm.
      %
      % Optional named arguments:
      %   guess     im     Initial guess at phase pattern.
      %     Image must be complex amplitude or real phase in range 0 to 2*pi.
      %     If not image is supplied, a guess is created using invmethod.
      %
      %   adaptive  num    Adaptive-Adaptive factor.  Default: 1.0, i.e.
      %     the method is Gerchberg-Saxton.
      %
      %   vismethod fcn    Function to calculate far-field.  Takes one
      %     argument: the complex amplitude near-field.
      %   invmethod fcn    Function to calculate near-field.  Takes one
      %     argument: the complex amplitude far-field.
      %   objective fcn    Objective function to measure fitness.
      %   visdata   cell   Cell array of arguments to pass to vismethod.
      %   invdata   cell   Cell array of arguments to pass to invmethod.

      % Parse inputs
      p = inputParser;
      p.addRequired('target');
      p.addParameter('guess', []);
      p.addParameter('adaptive', 1.0);
      p.addParameter('vismethod', @otslm.iter.IterBase3d.defaultVisMethod);
      p.addParameter('invmethod', @otslm.iter.IterBase3d.defaultInvMethod);
      p.addParameter('visdata', {});
      p.addParameter('invdata', {});
      p.addParameter('objective', @otslm.iter.objectives.flatintensity);
      p.addParameter('objective_type', 'min');
      p.parse(varargin{:});

      % Call base class for most handling
      mtd = mtd@otslm.iter.IterBase3d(p.Results.target, ...
          'guess', p.Results.guess, ...
          'vismethod', p.Results.vismethod, ...
          'invmethod', p.Results.invmethod, ...
          'visdata', p.Results.visdata, ...
          'invdata', p.Results.invdata, ...
          'objective', p.Results.objective, ...
          'objective_type', p.Results.objective_type);

      % Store adaptive-adaptive factor
      mtd.adaptive = p.Results.adaptive;

    end

    function result = iteration(mtd)
      % Implementation of the 3-D Gerchberg-Saxton algorithm

      % TODO: This isn't different from 2-D GS, can we merge it with
      %   the 2-D GS implementation somehow?

      % Calculate generated pattern from guess
      B = exp(1i*mtd.guess);
      output = mtd.vismethod(B, mtd.visdata{:});

      % Do adaptive-adaptive step
      targetAmplitude = mtd.adaptive.*abs(mtd.target) ...
          + (1 - mtd.adaptive).*abs(output);

      % Calculate new guess
      D = targetAmplitude .* exp(1i*angle(output));
      mtd.guess = angle(mtd.invmethod(D, mtd.invdata{:}));

      % Return the latest guess
      result = mtd.guess;

      % Evaluate the fitness
      mtd.fitness(end+1) = mtd.evaluateFitness();

    end
  end

end
