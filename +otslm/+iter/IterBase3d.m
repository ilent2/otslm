classdef IterBase3d < otslm.iter.IterBase
% ITERBASE3D base class for 3-D iterative algorithm classes
%
% Methods
%   run()         Run the iterative method
%
% Properties
%   guess         Best guess at hologram pattern
%   target        Target pattern the method tries to approximate
%   vismethod     Method used to do the visualisation
%   invmethod     Method used to calculate initial guess/inverse-visualisation
%   visdata       Additional arguments to pass to vismethod
%   invdata       Additional arguments to pass to invmethod
%   objective     Objective function used to evaluate fitness
%   fitness       Fitness evaluated after every iteration
%
% Abstract methods:
%   iteration()       run a single iteration of the method
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  methods (Static)
    function output = defaultVisMethod(input, varargin)
      % Calculate the far-field of the device from the near-field
      % Takes a 2-D hologram and produces a 3-D volume

      p = inputParser;
      p.addParameter('incident', []);
      p.addParameter('NA', 0.1);
      p.addParameter('zsize', []);
      p.parse(varargin{:});

      % Calculate focal_length from NA
      diameter = sqrt(size(input, 1).^2 + size(input, 2).^2);
      focal_length = diameter./tan(asin(p.Results.NA)).*2;

      if isreal(input)
        error('input must be complex');
      end

      % Convert hologram to volume
      input = otslm.tools.hologram2volume(input, ...
        'focal_length', focal_length, ...
        'padding', 0, 'zsize', p.Results.zsize);
      
      % Calculate padding
      padding = size(input)/2;
      
      trim_padding = true;
      if numel(padding) == 2
        padding(3) = 0;
        trim_padding = false;
      end

      output = otslm.tools.visualise(input, ...
          'incident', p.Results.incident, ...
          'padding', padding, 'trim_padding', trim_padding, ...
          'method', 'fft3', 'NA', p.Results.NA);
    end

    function output = defaultInvMethod(input, varargin)
      % Calculate the near-field of the device from the far-field
      % Takes a 3-D volume and produces a 2-D hologram

      % TODO: Can this be merged with otslm.tools.visualize inverse?

      p = inputParser;
      p.addParameter('NA', 0.1);
      p.parse(varargin{:});

      % Calculate focal_length from NA
      diameter = sqrt(size(input, 1).^2 + size(input, 2).^2);
      focal_length = diameter./tan(asin(p.Results.NA)).*2;

      zpadding = size(input, 3)/2;
      pad = [size(input, 1)/2, size(input, 2)/2];

      % Do inverse Fourier transform
      input = padarray(input, [pad, zpadding]);
      input = fftshift(input);
      output = ifftn(input);
      output = output(pad(1):end-pad(1)-1, pad(2):end-pad(2)-1, :);

      % Convert from 3-D volume to 2-D hologram
      output = otslm.tools.volume2hologram(output, ...
          'focal_length', focal_length, ...
          'padding', zpadding);
    end
  end

  methods
    function mtd = IterBase3d(varargin)
      % Abstract constructor for 3-D iterative algorithm base class
      %
      % mtd = IterBase3d(target, ...)
      %
      % Optional named arguments:
      %   guess     im     Initial guess at phase pattern.
      %     Image must be complex amplitude or real phase in range 0 to 2*pi.
      %     If not image is supplied, a guess is created using invmethod.
      %   vismethod fcn    Function to calculate far-field.  Takes one
      %     argument: the complex amplitude near-field.
      %   invmethod fcn    Function to calculate near-field.  Takes one
      %     argument: the complex amplitude far-field.
      %   visdata   {}     Cell array of data to pass to vis function
      %   invdata   {}     Cell array of data to pass to inv function
      %   objective fcn    Objective function to measure fitness.

      % Parse inputs
      p = inputParser;
      p.addRequired('target');
      p.addParameter('guess', []);
      p.addParameter('vismethod', @otslm.iter.IterBase3d.defaultVisMethod);
      p.addParameter('invmethod', @otslm.iter.IterBase3d.defaultInvMethod);
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
    end
  end
end
