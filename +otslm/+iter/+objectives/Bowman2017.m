classdef Bowman2017 < otslm.iter.objectives.Objective
%BOWMAN2017 cost function used in Bowman et al. 2017 paper.
%
%   C = 10^d * (1.0 - \sum_{nm} sqrt(I_nm T_nm) cos(phi_nm - psi_nm)).^2
%
% target and trial should be the complex field amplitudes.
%
% Properties:
%    scale      `d` scaling factor in cost function
%    type       'both', 'phase', or 'amplitude' for optimisation type
%    normalize  Normalize target/trial every evaluation
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties
  	scale      % `d` scaling factor in cost function
    type       % 'both', 'phase', or 'amplitude' for optimisation type
    normalize  % Normalize target/trial every evaluation
  end

  methods
    function obj = Bowman2017(varargin)
      %BOWMAN2017 construct a new objective function instance
      %
      % obj = Bowman2017(...) construct a new objective function instance.
      %
      % Optional named arguments:
      %   scale   num   `d` scaling factor in cost function.
      %       Default: 0.5
      %
      %   type    [char]   One of 'both', 'phase', or 'amplitude'
      %       for optimisation type.  Default: 'both'.
      %
      %   normalize   bool    Normalize target/trial every
      %       evaluation.  Default: true.
      %
      %   roi   [] | logical | function_handle     specify the roi
      %       to use when evaluating the fitness function.
      %       Can be a logical array or a function handle.
      %       Default: []
      %
      %   target   [] | matrix    specify the target pattern for this
      %       objective.  If not supplied, the target must be supplied
      %       when the evaluate function is called.
      %       Default: []
      
      p = inputParser;
      p.KeepUnmatched = true;
      p.addParameter('type', 'both');
      p.addParameter('normalize', true);
      p.addParameter('scale', 0.5);
      p.parse(varargin{:});
      
      unmatched = [fieldnames(p.Unmatched).'; struct2cell(p.Unmatched).'];
      obj = obj@otslm.iter.objectives.Objective(unmatched{:});
      
      obj.scale = p.Results.scale;
      obj.normalize = p.Results.normalize;
      obj.type = p.Results.type;
    end
    
    function obj = set.type(obj, value)
      % Check for valid type
      assert(any(strcmpi(value, {'both', 'phase', 'amplitude'})), ...
        'type must be one of ''both'', ''phase'' or ''amplitude''');
      obj.type = value;
    end
  end
  
  methods (Hidden)
    function fitness = evaluate_internal(obj, target, trial)
      % Cost function used in Bowman et al. 2017 paper.
      %
      % Range: [+Inf, 0] (0 = best match)
      
      % Calculate the target intensity and amplitude
      phi = angle(target);
      T = abs(target).^2;

      % Calculate the current intensity and amplitude
      psi = angle(trial);
      I = abs(trial).^2;

      % Switch between the different types
      switch obj.type
        case 'amplitude'
          % Throw away phase information
          phi = zeros(size(phi));
          psi = zeros(size(psi));
        case 'phase'
          % Throw away amplitude information
          I = ones(size(I));
          T = ones(size(T));
        otherwise
          % Keep both
      end
      
      tol = eps(1);

      % Calculate cost
      overlap = sum(sqrt(T(:).*I(:)) .* cos(psi(:) - phi(:)));
      if obj.normalize && abs(overlap) > tol
        overlap = overlap / sqrt(sum(T(:)) * sum(I(:)));
      end
      fitness = 10^obj.scale * (1.0 - overlap).^2;
    end
  end
end

