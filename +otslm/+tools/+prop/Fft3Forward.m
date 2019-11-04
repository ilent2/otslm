classdef Fft3Forward < otslm.tools.prop.Fft3Base
% Propagate using forward 3-D fast Fourier transform
%
% Methods
%  - Fft3Forward() -- construct a new propagator instance
%  - propagate()   -- propagate the field forward using 3-D FFT
%
% Properties
%  - data       -- Memory allocated for transform input
%  - padding    -- Padding around image
%  - size       -- Size of image
%  - roi        -- Region of interest within data for image
%  - roi_output -- Region to crop output image after transformation
%
% Static methods
%  - simple()     -- propagate the field with a simple interface
%  - simpleProp() -- construct the propogator for input pattern
%
% See also Fft3Inverse, FftForward and otslm.tools.visualise.

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties
    convfilt      % If ~isempty, specifies a convolutional filter matrix
  end
  
  methods (Static)
    
    function prop = simpleProp(pattern, varargin)
      % Generate the propagator for the specified pattern.
      %
      % prop = simpleProp(pattern, ...) construct a new propagator.
      %
      % Optional named arguemnts:
      %  - padding  num | [num, num]  Padding for transform.
      %    For details, see FftForward.  Default: ceil(size(pattern)/2)
      %  - trim_padding   bool   if padding should be trimmed from output.
      %    Default: true.
      %  - gpuArray    bool     if we should use the GPU.
      %    Default: ``isa(pattern, 'gpuArray')``
      
      p = inputParser;
      p.addParameter('padding', ceil(size(pattern)/2));
      p.addParameter('trim_padding', true);
      p.addParameter('gpuArray', isa(pattern, 'gpuArray'));
      p.parse(varargin{:});
      
      % Construct propagator
      prop = otslm.tools.prop.Fft3Forward(size(pattern), ...
        'padding', p.Results.padding, ...
        'trim_padding', p.Results.trim_padding, ...
        'gpuArray', p.Results.gpuArray);
    end

    function [output, prop] = simple(pattern, varargin)
      % propagate the field with a simple interface
      %
      % [output, prop] = simple(pattern, ...) construct a new FFT
      % propogator and apply it to the pattern.  Returns the
      % propagated pattern and the propagator.
      %
      % See also :meth:`simpleProp` for named arguments.

      prop = otslm.tools.prop.Fft3Forward.simpleProp(pattern, varargin{:});

      % Apply propagator
      output = prop.propagate(pattern);

    end
  end

  methods
    function obj = Fft3Forward(sz, varargin)
      % Construct a FFT propagator instance
      %
      % FFT3FORWARD(sz, ...) construct a new propagator instance
      % for the specified pattern size.  sz must be a 3 element vector.
      %
      % Optional named arguments:
      %  - padding    num | [xy, z] | [x, y, z] padding to add to edges of
      %    the image.  Either a single number for uniform padding,
      %    two numbers for separate axial and radial padding,
      %    or three numbers for x, y and z padding.
      %    Default: ceil(sz/2)
      %
      %  - trim_padding   bool   if the output_roi should be set
      %    to remove the padding added before the transform.
      %    Default: false.
      %
      %  - gpuArray   bool    if true, allocates memory on the GPU
      %    and does the transform with the GPU instead of the CPU.
      %    Default: false.

      p = inputParser;
      p.KeepUnmatched = true;
      p.addParameter('convfilt', []);
      p.parse(varargin{:});
      
      % Construct base
      unmatched = [fieldnames(p.Unmatched).'; struct2cell(p.Unmatched).'];
      obj = obj@otslm.tools.prop.Fft3Base(sz, unmatched{:});
      
      % Store our parameters
      obj.convfilt = p.Results.convfilt;
    end
  end
  
  methods (Access=protected)
    function output = propagate_internal(obj)
      % Apply the forward propagation method
      
      % Apply Gaussian filter to remove high frequency noise
      if ~isempty(obj.convfilt)
        output = convn(obj.data, obj.convfilt, 'same');
      else
        output = obj.data;
      end
      
      % Transform to the focal plane (missing scaling factor)
      output = fftshift(fftn(output))./numel(output);
    end
  end
end
