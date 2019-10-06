classdef (Abstract) Objective
%OBJECTIVE Base class for optimisation objective functions
%
% Methods:
%   evaluate()            Evaluate the fitness of the specified pattern
%
% Properties:
%   target        Target pattern to compare with (or [] for no default)
%   roi           Region of interest to apply to target and trial
%
% Abstract methods:
%   evaluate_internal()   Implementation called by evaluate()
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties
    target        % Target pattern to compare with (or [] for no default)
    roi           % Region of interest to apply to target and trial
  end

  methods
    function obj = Objective(varargin)
      %OBJECTIVE construct a new objective function instance
      %
      % obj = Objective(...) construct a new objective function instance.
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
      
      p = inputParser();
      p.addParameter('roi', []);
      p.addParameter('target', []);
      p.parse(varargin{:});
      
      obj.roi = p.Results.roi;
      obj.target = p.Results.target;
    end
    
    function fitness = evaluate(obj, trial, target)
      %EVALUATE evalute the fitness of the specified trial pattern
      %
      % fitness = obj.evaluate(trial, [target]) evaluate the specified
      %   trial pattern.  If target is not specified, uses the internal
      %   target pattern set during construction.
      
      % Handle default target
      if nargin < 3
        if ~isempty(obj.target)
          target = obj.target;
        else
          error('Must supply target to evaluate or objective constructor');
        end
      end
      
      % Apply ROI
      if isa(obj.roi, 'function_handle')
        target = obj.roi(target);
        trial = obj.roi(trial);
      elseif isa(obj.roi, 'logical')
        target = target(obj.roi);
        trial = trial(obj.roi);
      elseif isempty(obj.roi)
        % Nothing to do
      else
        error('roi must be logical or function_handle');
      end
      
      % call evaluate_internal
      fitness = obj.evaluate_internal(target, trial);
    end
    
    function obj = set.roi(obj, val)
      % Check value for roi
      assert(islogical(val) || isempty(val) || isa(val, 'function_handle'), ...
        'roi must be empty, logical or a function_handle');
      obj.roi = val;
    end
  end
  
  methods (Abstract, Hidden)
    evaluate_internal(obj, target, trial)
  end
end

