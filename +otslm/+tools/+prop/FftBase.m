classdef (Abstract) FftBase < otslm.tools.prop.Propagator
%FFTBASE Abstract base class for Fft* propagator methods
%
% Abstract methods:
%   propagate_internal(obj)    method called by propogate().
%
% See also FftForward, FftInverse and otslm.tools.visualise.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.
  
  properties (SetAccess=protected)
    data         % Memory allocated for the transform
    lens         % Lens function to add before transformation
    padding      % Padding around image
    size         % Size of images we can transform
  end
  
  properties
    % Region of interest in output image [XMIN YMIN WIDTH HEIGHT]
    % This is applied at the end of the propogate method.  Default: [].
    roi_output
  end
  
  properties (Dependent)
    roi          % Region of interest in data
  end
  
  methods (Static)
    function lens = calculateLens(sz, NA, z)
      % Calculate lens function used by FftForward.simple
      % and FftInverse.simple.
      %
      % lens = calculateLens(sz, NA, z)
      % calculates the lens for the specified size, NA and axial_offset.
      
      % Calculate lens
      if z ~= 0
        % Set rscale from inputs, this is determined by the
        % focal length/numerical aparture of the lens (for z-shift)
        rscale = 1.0./NA;

        lens = otslm.simple.spherical(sz, ...
            rscale*sqrt(sum((sz/2).^2)), ...
            'background', 'checkerboard');

        % Apply z-shift using a lens in the far-field
        lens = exp(-1i*z*lens);
      else
        lens = [];
      end
    end
  end
  
  methods (Abstract, Access=protected)
    propagate_internal(obj)    % Internal propagation method
  end
  
  methods
    function obj = FftBase(sz, varargin)
      %FFTBASE Construct a FFT 2-D propagator instance
      %
      % For description of arguments, see FftForward or FftInverse.
      
      p = inputParser;
      p.addParameter('padding', ceil(sz/2));
      p.addParameter('lens', []);
      p.addParameter('trim_padding', false);
      p.addParameter('gpuArray', false);
      p.parse(varargin{:});
      
      assert(numel(sz) == 2, 'size must be a 2 element vector');
      obj.size = sz;
      
      % Parse padding argument
      switch numel(p.Results.padding)
        case 0
          obj.padding = [0, 0];
        case 1
          obj.padding = [1, 1].*p.Results.padding;
        case 2
          obj.padding = p.Results.padding;
        otherwise
          error('Padding must be 0, 1 or 2 element vector');
      end
      
      % Calculat total image size
      total_sz = obj.size + 2*obj.padding;
      
      % Check size of lens
      assert(isempty(p.Results.lens) || all(total_sz == size(p.Results.lens)), ...
        'Lens must have same size as sz + padding');
      
      % Allocate memory for transform and lens
      if p.Results.gpuArray
        obj.data = gpuArray.zeros(total_sz);
        if ~isempty(p.Results.lens)
          obj.lens = gpuArray(p.Results.lens);
        else
          obj.lens = [];
        end
      else
        obj.data = zeros(total_sz);
        obj.lens = p.Results.lens;
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
      obj.data(obj.roi(2)-1 + (1:obj.roi(4)), ...
        obj.roi(1)-1 + (1:obj.roi(3))) = input;
      
      output = obj.propagate_internal();

      % Remove padding if requested
      if ~isempty(obj.roi_output)
        output = output(obj.roi_output(2)-1 + (1:obj.roi_output(4)), ...
            obj.roi_output(1)-1 + (1:obj.roi_output(3)));
      end
    end
    
    function roi = get.roi(obj)
      % Return a rect for the ROI [XMIN YMIN WIDTH HEIGHT]
      roi = [flip(obj.padding)+1, flip(obj.size)];
    end
    
    function obj = set.roi_output(obj, val)
      % Check size of output region of interest
      assert(numel(val) == 4 || numel(val) == 0, ...
        'output roi must be empty or have 4 values');
      obj.roi_output = val;
    end
  end
end