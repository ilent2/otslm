classdef (Abstract) Fft3Base < otslm.tools.prop.Propagator
% Abstract base class for Fft3* propagator methods
% Inherits from :class:`Propagator`
%
% Properties
%   - data    -- Memory allocated for the transform
%   - padding -- Padding around image
%   - size    -- size of images we can transform
%
% Abstract methods:
%   - propagate_internal(obj)  -- method called by propogate().
%
% See also Fft3Forward, Fft3Inverse and otslm.tools.visualise.

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties (SetAccess=protected)
    data         % Memory allocated for the transform
    padding      % Padding around image
    size         % Size of images we can transform
  end

  properties
    % Region of interest in output image [XMIN YMIN ZMIN WIDTH HEIGHT DEPTH]
    % This is applied at the end of the propogate method.  Default: [].
    roi_output
  end
  
  properties (Dependent)
    roi          % Region of interest in data
  end
  
  methods (Abstract, Access=protected)
    propagate_internal(obj)    % Internal propagation method
  end
  
  methods
    function obj = Fft3Base(sz, varargin)
      %FFTBASE Construct a FFT 3-D propagator instance
      %
      % For description of arguments, see Fft3Forward or Fft3Inverse.
      
      p = inputParser;
      p.addParameter('padding', ceil(sz/2));
      p.addParameter('trim_padding', false);
      p.addParameter('gpuArray', false);
      p.parse(varargin{:});
      
      assert(numel(sz) == 3, 'size must be a 3 element vector');
      assert(all(round(sz) == sz), 'size must be integers');
      assert(all(sz >= 1), 'size must be positive numbers');
      obj.size = sz;
      
      % Parse padding argument
      switch numel(p.Results.padding)
        case 0
          obj.padding = [0, 0, 0];
        case 1
          obj.padding = [1, 1, 1].*p.Results.padding;
        case 2
          obj.padding = [p.Results.padding(1), ...
              p.Results.padding(1), p.Results.padding(2)];
        case 3
          obj.padding = p.Results.padding;
        otherwise
          error('Padding must be 0, 1, 2 or 3 element vector');
      end
      
      % Calculat total image size
      total_sz = obj.size + 2*obj.padding;
      
      % Allocate memory for transform and lens
      if p.Results.gpuArray
        obj.data = gpuArray.zeros(total_sz);
      else
        obj.data = zeros(total_sz);
      end
      
      % Set the output roi
      if p.Results.trim_padding
        obj.roi_output = obj.roi;
      else
        obj.roi_output = [];
      end
    end
    
    function output = propagate(obj, input, varargin)
      % Propogate the input image
      %
      % output = propagate(input, ...) propogates the complex input
      % image using the 2-D inverse FFT method.
      
      assert(all(size(input) == obj.size), ...
        'input must match Propagator.size');
      
      % Copy input into padded array
      obj.data(obj.roi(2)-1 + (1:obj.roi(5)), ...
        obj.roi(1)-1 + (1:obj.roi(4)), ...
        obj.roi(3)-1 + (1:obj.roi(6))) = input;
      
      output = obj.propagate_internal();

      % Remove padding if requested
      if ~isempty(obj.roi_output)
        output = output(obj.roi_output(2)-1 + (1:obj.roi_output(5)), ...
            obj.roi_output(1)-1 + (1:obj.roi_output(4)), ...
            obj.roi_output(3)-1 + (1:obj.roi_output(6)));
      end
    end
    
    function roi = get.roi(obj)
      % Return a rect for the ROI [XMIN YMIN ZMIN WIDTH HEIGHT DEPTH]
      roi = [obj.padding([2, 1, 3])+1, obj.size([2, 1, 3])];
    end
    
    function obj = set.roi_output(obj, val)
      % Check size of output region of interest
      assert(numel(val) == 6 || numel(val) == 0, ...
        'output roi must be empty or have 4 values');
      obj.roi_output = val;
    end
  end
end
