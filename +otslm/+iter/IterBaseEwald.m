classdef IterBaseEwald < otslm.iter.IterBase
% Abstract base class for 3-D Ewald iterative algorithm classes
% Inherits from :class:`IterBase`.
%
% Methods
%   - run()      -- Run the iterative method
%
% Properties
%   - guess      -- Best guess at hologram pattern (complex, matrix)
%   - target     -- Target pattern the method tries to approximate (volume)
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
%   - iteration()   --  run a single iteration of the method

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  methods
    function mtd = IterBaseEwald(target, varargin)
      % Abstract constructor for 3-D iterative algorithm base class
      %
      % Usage
      %   mtd = IterBaseEwald(target, ...) constructs a new instance.
      %   target should be a 3-D volume.  Guess, if supplied, should be
      %   a 2-D matrix for the pattern on the SLM.
      %
      % Optional named arguments:
      %   - guess     im     Initial guess at complex amplitude pattern.
      %     If no image is supplied, a guess is created using invmethod.
      %
      %   - vismethod fcn    Function to calculate far-field.  Takes one
      %     argument: the complex amplitude near-field.
      %     Default: @otslm.tools.prop.FftEwaldForward.simpleProp.propagate
      %
      %   - invmethod fcn    Function to calculate near-field.  Takes one
      %     argument: the complex amplitude far-field.
      %     Default: @otslm.tools.prop.FftEwaldInverse.simpleProp.propagate
      %
      %   - objective fcn    Objective function to measure fitness.
      %     Default: @otslm.iter.objectives.FlatIntensity

      % Parse inputs
      p = inputParser;
      p.KeepUnmatched = true;
      p.addParameter('guess', []);
      p.addParameter('vismethod', []);
      p.addParameter('invmethod', []);
      p.addParameter('gpuArray', []);
      p.parse(varargin{:});
      
      % Handle default gpuArray argument
      useGpuArray = p.Results.gpuArray;
      if isempty(useGpuArray)
        useGpuArray = isa(target, 'gpuArray') || isa(p.Results.guess, 'gpuArray');
      end
      
      vismethod = p.Results.vismethod;
      invmethod = p.Results.invmethod;
      
      % Handle default visualisation and inverse methods
      if isempty(vismethod)
        prop = otslm.tools.prop.FftEwaldForward.simpleProp(target(:, :, 1), ...
            'gpuArray', useGpuArray, 'zsize', size(target, 3));
        vismethod = @prop.propagate;
      end
      if isempty(invmethod)
        prop = otslm.tools.prop.FftEwaldInverse.simpleProp(target, ...
            'gpuArray', useGpuArray);
        invmethod = @prop.propagate;
      end
      
      % Get unmatched parameters
      unmatched = [fieldnames(p.Unmatched).'; struct2cell(p.Unmatched).'];

      % Call base class for most handling
      mtd = mtd@otslm.iter.IterBase(target, unmatched{:}, ...
          'guess', p.Results.guess, ...
          'vismethod', vismethod, ...
          'invmethod', invmethod, ...
          'gpuArray', useGpuArray);
    end
  end
end
