classdef Flatness < otslm.iter.objectives.Objective
%FLATNESS objective function for pattern flatness
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  methods
    function obj = Flatness(varargin)
      %FLATNESS construct a new objective function instance
      %
      % obj = Flatness(...) construct a new objective function instance.
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
      % Function to promote flatness of the pattern
      %
      % Range: [+Inf, 0] (0 = flat)
      
      tol = eps(1);
      
      T = abs(target(:)).^2;
      I = abs(trial(:)).^2 .* T;
      mI = mean(I);
      
      if mI <= tol
        fitness = 0.0;
      else
        fitness = sum(T) .* sqrt( mean(( I - mI ).^2) ) ./ mI;
      end
    end
  end
end

