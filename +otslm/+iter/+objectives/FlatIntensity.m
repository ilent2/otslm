classdef FlatIntensity < otslm.iter.objectives.Flatness ...
    & otslm.iter.objectives.Intensity
% Objective function for pattern flatness and intensity.
% Inherits from :class:`Intensity` and :class:`Flatness`.
%
% Evaluates the fitness using the Intensity and Flatness method
% and adds the result:
%
% .. code:
%
%   fitness = I + obj.flatness*F
%
% Properties
%   - flatness -- scaling factor for pattern flatness
%
% See also FlatIntensity and :class:`Bowman2017`.

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties
    flatness       % Scaling factor for pattern flatness
  end

  methods
    function obj = FlatIntensity(varargin)
      % Construct a new objective function instance
      %
      % Usage
      %   obj = FlatIntensity(...)
      %
      % Optional named arguments
      %   - roi   [] | logical | function_handle --  specify the roi
      %     to use when evaluating the fitness function.
      %     Can be a logical array or a function handle.
      %     Default: []
      %
      %   - target   [] | matrix -- specify the target pattern for this
      %     objective.  If not supplied, the target must be supplied
      %     when the evaluate function is called.
      %     Default: []
      %
      %   - flatness    num --  Scaling factor for pattern flatness.
      %     Default: 0.5.

      p = inputParser;
      p.KeepUnmatched = true;
      p.addParameter('flatness', 0.5);
      p.parse(varargin{:});

      % Construct base classes
      unmatched = [fieldnames(p.Unmatched).'; struct2cell(p.Unmatched).'];
      obj = obj@otslm.iter.objectives.Flatness(unmatched{:});
      obj = obj@otslm.iter.objectives.Intensity(unmatched{:});

      obj.flatness = p.Results.flatness;
    end
  end

  methods (Hidden)
    function fitness = evaluate_internal(obj, target, trial)
      % Function to promote flatness of the pattern
      %
      % Range: [+Inf, -Inf] (smaller = better)

      F = evaluate_internal@otslm.iter.objectives.Flatness(obj, target, trial);
      I = evaluate_internal@otslm.iter.objectives.Intensity(obj, target, trial);

      fitness = I + obj.flatness*F;
    end
  end
end

