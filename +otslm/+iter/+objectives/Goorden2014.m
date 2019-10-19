classdef Goorden2014 < otslm.iter.objectives.Objective
% Fidelity function from Goorden, et al. 2014 paper.
%
% .. math::
%
%   F = |\textrm{conj}(target) * trial|^2
%
% Error is 1 - F.
%
% Properties
%   - normalize (logical) -- True if the patterns should be normalized
%     by the area (i.e., :math:`F = F/A^2`).
%
% See also Goorden2014, :class:`Flatness` and :class`Bowman2017`.

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties
    normalize      % If the pattern should be normalized by the area
  end

  methods
    function obj = Goorden2014(varargin)
      % Construct a new objective function instance
      %
      % Usage
      %   obj = Goorden2014(...)
      %
      % Optional named arguments
      %   - normalize    logical --  If true, normalized the pattern
      %     by the number of pixels in the pattern.  Default: true.
      %
      %   - roi   [] | logical | function_handle  -- specify the roi
      %     to use when evaluating the fitness function.
      %     Can be a logical array or a function handle.
      %     Default: []
      %
      %   - target   [] | matrix -- specify the target pattern for this
      %     objective.  If not supplied, the target must be supplied
      %     when the evaluate function is called.
      %     Default: []

      p = inputParser;
      p.KeepUnmatched = true;
      p.addParameter('normalize', true);
      p.parse(varargin{:});
      
      unmatched = [fieldnames(p.Unmatched).'; struct2cell(p.Unmatched).'];
      obj = obj@otslm.iter.objectives.Objective(unmatched{:});
      
      obj.normalize = p.Results.normalize;
    end
  end
  
  methods (Hidden)
    function fitness = evaluate_internal(obj, target, trial)
      % Cost function used in Bowman et al. 2017 paper.
      %
      % Range: [+Inf, 0] (0 = best match)
      
      % Calculate fidelity
      F = abs(sum(conj(target(:)).*trial(:))).^2;
      
      % Normalize by number of pixels (makes result closer to unity)
      if obj.normalize
        F = F ./ numel(target).^2;
      end

      % Calculate error
      fitness = 1.0 - F;
    end
  end
end

