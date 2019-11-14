classdef GerchbergSaxton3d < otslm.iter.IterBaseEwald ...
    & otslm.iter.GerchbergSaxton
% Implementation of 3-D Gerchberg-Saxton and Adaptive-Adaptive algorithms
% Inherits from :class:`GerchbergSaxton` and :class:`IterBaseEwald`.
%
% This algorithm attempts to recreate the target volume using
% the 3-D analog of the Gerchberg-Saxton algorithm.
%
% See Hao Chen et al 2013 J. Opt. 15 035401
% and Graeme Whyte and Johannes Courtial 2005 New J. Phys. 7 117
%
% Methods
%   - run()     --  Run the iterative method
%
% Properties
%   - adaptive  --  Adaptive-adaptive factor (1 for Gerchberg-Saxton)
%
% Inherited properties
%   - guess     --  Best guess at hologram pattern
%   - target    --  Target pattern the method tries to approximate
%   - vismethod --  Method used to do the visualisation
%   - invmethod --  Method used to calculate initial guess/inverse-visualisation
%   - objective --  Objective function used to evaluate fitness
%   - fitness   --  Fitness evaluated after every iteration
%
% See also GerchbergSaxton3d and :class:`GerchbergSaxton`.

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  methods
    function mtd = GerchbergSaxton3d(target, varargin)
      % Construct a new instance of the GerchbergSaxton3d iterative method
      %
      % USage
      %   mtd = GerchbergSaxton3d(target, ...)
      %
      % Parameters
      %   - target -- target pattern to try and generate
      %
      % Optional named arguments
      %   - adaptive  num -- Adaptive-Adaptive factor.  Default: 1.0, i.e.
      %     the method is Gerchberg-Saxton.
      %
      %   - guess     im  -- Initial guess at complex amplitude pattern.
      %     If not image is supplied, a guess is created using invmethod.
      %
      %   - vismethod fcn -- Function to calculate far-field.  Takes one
      %     argument: the complex amplitude near-field.
      %     Default: @otslm.tools.prop.FftEwaldForward.simpleProp.propagate
      %
      %   - invmethod fcn -- Function to calculate near-field.  Takes one
      %     argument: the complex amplitude far-field.
      %     Default: @otslm.tools.prop.FftEwaldInverse.simpleProp.propagate
      %
      %   - objective fcn -- Optional objective function to measure fitness.
      %     Default: @otslm.iter.objectives.FlatIntensity

      % Parse inputs
      p = otslm.iter.GerchbergSaxton.inputParser(varargin{:});
      
      % Construct GS (this assumes 2-D forward/inverse methods)
      results = [fieldnames(p.Results).'; struct2cell(p.Results).'];
      mtd = mtd@otslm.iter.GerchbergSaxton(target(:, :, 1), results{:});
      
      % Construct everything else with Ewald (3-D forward/inverse methods)
      unmatched = [fieldnames(p.Unmatched).'; struct2cell(p.Unmatched).'];
      mtd = mtd@otslm.iter.IterBaseEwald(target, unmatched{:});

    end
  end
end
