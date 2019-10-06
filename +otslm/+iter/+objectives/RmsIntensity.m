classdef RmsIntensity < otslm.iter.objectives.Objective
%RMSINTENSITY objective function for pattern RMS intensity
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  methods
    function obj = RmsIntensity(varargin)
      %RMSINTENSITY construct a new objective function instance
      %
      % obj = RmsIntensity(...) construct a new objective function instance.
      %
      % Optional named arguments:
      %   roi   [] | logical | function_handle     specify the roi
      %       to use when evaluating the fitness function.
      %       Can be a logical array or a function handle.
      %       Default: []
      %
      %   target   [] | matrix    specify the target pattern for this
      %       objective.  If not supplied, the target must be supplied
      %       when the evaluate function is called.
      %       Default: []
      
      obj = obj@otslm.iter.objectives.Objective(varargin{:});
    end
  end
  
  methods (Hidden)
    function fitness = evaluate_internal(obj, target, trial)
      % Function to promote RMS intensity similarity of the pattern
      %
      % Range: [+Inf, 0] (0 = most similar)
      
      fitness = sqrt(mean((abs(target(:)).^2 - abs(trial(:)).^2).^2));
    end
  end
end

