classdef (Abstract) Objective
% Abstract base class for optimisation objective functions.
%
% To use this class, you need to inherit from it and implement
% the evaluate_internal function.
%
% Methods
%  - evaluate() -- Evaluate the fitness of the specified pattern
%
% Properties
%  - target (numeric)    -- Target pattern to compare with
%    (or [] for no default).  This is only used if no target is
%    provided in evaluate().
%
%  - type (enum)         -- Type of optimisation function ('min' or 'max')
%    This property isn't widely used (may change in future version).
%    For now, most functions simply have this property set to 'min'.
%
%  - roi (logical|empty|function_handle) -- Region of interest to apply to
%    target and trial.  Must be either a logical array the same size
%    as target, an empty matrix for no roi, or a function handle.
%    If roi is a function handle, the function should have the
%    signature ``masked = roi(pattern)``.  Calling the function should
%    select elements from the pattern for comparison.  The function
%    is applied to both the target and the trial pattern.
%
% Abstract methods
%   - evaluate_internal()  -- Implementation called by evaluate().
%     Signature: :code:`fitness = obj.evaluate_internal(target, trial)`.
%     The roi has already been applied to the trial and target.
%
% See also Objective, :class:`Intensity` and :class:`Flatness`.

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties
    target        % Target pattern to compare with (or [] for no default)
    roi           % Region of interest to apply to target and trial
    type          % Type of optimisation function ('min' or 'max')
  end

  methods
    function obj = Objective(varargin)
      % Construct a new objective function instance
      %
      % Usage
      %   obj = Objective(...) construct a new objective function instance.
      %
      % Optional named arguments
      %   - roi   [] | logical | function_handle  -- specify the roi
      %     to use when evaluating the fitness function.
      %     Can be a logical array or a function handle.
      %     Default: []
      %
      %   - target   [] | matrix -- specify the target pattern for this
      %     objective.  If not supplied, the target must be supplied
      %     when the evaluate function is called.
      %     Default: []

      p = inputParser();
      p.addParameter('roi', []);
      p.addParameter('target', []);
      p.parse(varargin{:});

      obj.roi = p.Results.roi;
      obj.target = p.Results.target;
      obj.type = 'min';
    end

    function fitness = evaluate(obj, trial, target)
      % Evaluate the fitness of the specified trial pattern.
      %
      % Usage
      %   fitness = obj.evaluate(trial, [target]) evaluate the specified
      %   trial pattern.  If target is not specified, uses the internal
      %   target pattern set during construction.
      %
      % Parameters
      %   - trial (numeric) -- pattern to compare to target
      %   - target (numeric) -- pattern to compare to trial.  Optional.
      %     Default target is obj.target.

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

