classdef FftForward < otslm.tools.prop.Propagator
%FFTFORWARD Propogate using forward 2-D fast fourier transform
%
% Methods:
%    FftForward()    construct a new propagator instance
%    propagate()     propagate the field forward using 2-D FFT
%
% Properties:
%    data        Memory allocated for transform input
%    lens        Lens to be applied before transformation
%    padding     Padding around image
%    size        Size of image
%    roi         Region of interest within data for image
%    roi_output  Region to crop output image after transformation
%
% Static methods:
%    simple()        propagate the field with a simple interface
%    calculateLens() lens function used by simple and FftInverse.simple.
%
% See also FftInverse, Fft3Forward and otslm.tools.visualise.
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
      % Calculate lens function used by simple and FftInverse.simple.
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
    
    function [output, prop] = simple(pattern, varargin)
      % propagate the field with a simple interface
      %
      % [output, prop] = simple(pattern, ...) construct a new FFT
      % propogator and apply it to the pattern.  Returns the
      % propagated pattern and the propagator.
      %
      % Optional named arguemnts:
      %    axial_offset    num   Offset along the propagation axis
      %       Default: 0.0.
      %    NA         num     Numerical aperture for axial offset lens.
      %       Default: 0.1.
      %    padding  num | [num, num]  Padding for transform.
      %       For details, see FftForward.  Default: ceil(size(pattern)/2)
      %    trim_padding   bool   if padding should be trimmed from output.
      %       Default: true.
      %    gpuArray    bool     if we should use the GPU.
      %       Default: isa(pattern, 'gpuArray')
      
      p = inputParser;
      p.addParameter('axial_offset', 0.0);
      p.addParameter('NA', 0.1);
      p.addParameter('padding', ceil(size(pattern)/2));
      p.addParameter('trim_padding', true);
      p.addParameter('gpuArray', isa(pattern, 'gpuArray'));
      p.parse(varargin{:});
      
      % Calculate lens
      lens = otslm.tools.prop.FftForward.calculateLens(...
        size(pattern)+2*p.Results.padding, ...
        p.Results.NA, p.Results.axial_offset);
      
      % Construct propagator
      prop = otslm.tools.prop.FftForward(size(pattern), ...
        'padding', p.Results.padding, ...
        'trim_padding', p.Results.trim_padding, ...
        'lens', lens, ...
        'gpuArray', p.Results.gpuArray);
      
      % Apply propagator
      output = prop.propagate(pattern);
      
    end
  end
  
  methods
    function obj = FftForward(sz, varargin)
      %FFTFORWARD Construct a FFT propagator instance
      %
      % FFTFORWARD(sz, ...) construct a new propagator instance
      % for the specified pattern size.  sz must be a 2 element vector.
      %
      % Optional named arguments:
      %    padding    num | [num, num]   padding to add to edges of
      %       the image.  Either a single number for uniform padding
      %       or two numbers to pass to the `padarray` function.
      %       Default: ceil(sz/2)
      %
      %    lens       pattern    lens function to add to the transform.
      %       This can be useful for shifting the pattern in the axial
      %       direction.  Pattern should have same size as sz + padding.
      %       The lens function should be a complex field amplitude.
      %       Default: [].
      %
      %    trim_padding   bool   if the output_roi should be set
      %       to remove the padding added before the transform.
      %       Default: false.
      %
      %    gpuArray   bool    if true, allocates memory on the GPU
      %       and does the transform with the GPU instead of the CPU.
      %       Default: false.
      
      p = inputParser;
      p.addParameter('padding', ceil(sz/2));
      p.addParameter('lens', []);
      p.addParameter('trim_padding', false);
      p.addParameter('gpuArray', false);
      p.parse(varargin{:});
      
      assert(numel(sz) == 2, 'size must be a 2 element vector');
      obj.size = sz;
      
      % Ensure padding has correct shape
      obj.padding = p.Results.padding;
      if numel(obj.padding) == 1
        obj.padding = [obj.padding, obj.padding];
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
      % image using the 2-D FFT method.
      
      assert(all(size(input) == obj.size), ...
        'input must match Propagator.size');
      
      % Copy input into padded array
      obj.data(obj.roi(2)-1 + (1:obj.roi(4)), ...
        obj.roi(1)-1 + (1:obj.roi(3))) = input;
      
      % Apply lens
      if ~isempty(obj.lens)
        our_data = obj.data .* obj.lens;
      else
        our_data = obj.data;
      end
      
      % Transform to the focal plane (missing scaling factor)
      output = fftshift(fft2(our_data))./numel(our_data);

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
