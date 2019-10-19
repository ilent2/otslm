classdef Intensity < otslm.iter.objectives.Objective
% Objective function for pattern intensity.
%
% See also Intensity, :class:`Flatness` and :class:`FlatIntensity`.

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  methods
    function obj = Intensity(varargin)
      % Construct a new objective function instance
      %
      % Usage
      %   obj = Intensity(...)
      %
      % Optional named arguments
      %   - roi   [] | logical | function_handle     specify the roi
      %     to use when evaluating the fitness function.
      %     Can be a logical array or a function handle.
      %     Default: []
      %
      %   - target   [] | matrix    specify the target pattern for this
      %     objective.  If not supplied, the target must be supplied
      %     when the evaluate function is called.
      %     Default: []

      obj = obj@otslm.iter.objectives.Objective(varargin{:});
    end
  end

  methods (Hidden)
    function fitness = evaluate_internal(obj, target, trial)
      % Function to promote intensity of the pattern
      %
      % Range: [0, -Inf] (-Inf = most intense)

      fitness = -1 * mean(abs(trial(:)).^2 .* abs(target(:)).^2);
    end
  end
end

