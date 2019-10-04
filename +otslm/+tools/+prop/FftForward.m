classdef FftForward < otslm.tools.prop.FftBase
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
  
  methods (Static)
    
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
      lens = otslm.tools.prop.FftBase.calculateLens(...
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
      
      obj = obj@otslm.tools.prop.FftBase(sz, varargin{:});
    end
  end
  
  methods (Access=protected)
    function output = propagate_internal(obj)
      % Apply the forward propagation method
      
      % Apply lens
      if ~isempty(obj.lens)
        our_data = obj.data .* obj.lens;
      else
        our_data = obj.data;
      end
      
      % Transform to the focal plane (missing scaling factor)
      output = fftshift(fft2(our_data))./numel(our_data);
    end
  end
end
