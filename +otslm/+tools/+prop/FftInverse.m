classdef FftInverse < otslm.tools.prop.FftBase
%FFTINVERSE Propogate using inverse 2-D fast fourier transform
%
% Methods:
%    FftInverse()    construct a new propagator instance
%    propagate()     propagate the field using 2-D inverse FFT
%
% Properties:
%    data        Memory allocated for transform input
%    lens        Lens to be applied after transformation
%    padding     Padding around image
%    size        Size of image
%    roi         Region of interest within data for image
%    roi_output  Region to crop output image after transformation
%
% Static methods:
%    simple()        propagate the field with a simple interface
%    simpleProp()    construct the propogator for input pattern
%    calculateLens() lens function used by simple and FftInverse.simple.
%
% See also FftForward, Fft3Inverse and otslm.tools.visualise.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.
  
  methods (Static)
    
    function prop = simpleProp(pattern, varargin)
      % Generate the propagator for the specified pattern.
      %
      % prop = simpleProp(pattern, ...) construct a new propagator.
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
      lens = otslm.tools.prop.FftBase.calculateLens(...
        size(pattern)+2*p.Results.padding, ...
        p.Results.NA, p.Results.axial_offset);
      
      % Construct propagator
      prop = otslm.tools.prop.FftInverse(size(pattern), ...
        'padding', p.Results.padding, ...
        'trim_padding', p.Results.trim_padding, ...
        'lens', conj(lens), ...
        'gpuArray', p.Results.gpuArray);
    end
    
    function [output, prop] = simple(pattern, varargin)
      % propagate the field with a simple interface
      %
      % [output, prop] = simple(pattern, ...) construct a new inverse FFT
      % propogator and apply it to the pattern.  Returns the
      % propagated pattern and the propagator.
      %
      % See also simpleProp for named arguments.
      
      prop = otslm.tools.prop.FftInverse.simpleProp(pattern, varargin{:});
      
      % Apply propagator
      output = prop.propagate(pattern);
      
    end
  end
  
  methods
    function obj = FftInverse(sz, varargin)
      %FFTINVERSE Construct a inverse FFT propagator instance
      %
      % FFTINVERSE(sz, ...) construct a new propagator instance
      % for the specified pattern size.  sz must be a 2 element vector.
      %
      % Optional named arguments:
      %    padding    num | [num, num]   padding to add to edges of
      %       the image.  Either a single number for uniform padding
      %       or two numbers to pass to the `padarray` function.
      %       Default: ceil(sz/2)
      %
      %    lens       pattern    lens function added after transformation.
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
      
      obj = obj@otslm.tools.prop.FftBase(sz, varargin{:});
    end
  end
  
  methods (Access=protected)
    function output = propagate_internal(obj)
      % Apply the inverse propagation method
      
      % Apply inverse fourier transform
      output = ifft2(fftshift(obj.data)).*numel(obj.data);
      
      % Apply lens
      if ~isempty(obj.lens)
        output = output .* obj.lens;
      end
    end
  end
end