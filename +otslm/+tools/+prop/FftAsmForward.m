classdef FftAsmForward < otslm.tools.prop.FftBase
% Propagate using pair of 2-D fast Fourier transforms.
%
% Implements the Angular Spectrum Method (ASM)
%
%   I = ifft(fft(I0)*H)
%
% where H is a propagator function.
%
% Unlike the FftForward propagator, this propagator assumes the field
% isn't being focussed by a lens, i.e., it is propagating just a short
% distance from the hologram.  When a lens is present, it is more
% efficient to use a single fourier transsform.
% 
% This method can be used to model acoustics
% when the amplitude and phase describe the pressure and phase.
%
% Methods
%  - FftAsmForward()  --  construct a new propagator instance
%  - propagate()   --  propagate the field forward using 2-D FFT
%
% Properties
%  - data       -- Memory allocated for transform input
%  - lens       -- Lens to be applied after transformation
%  - padding    -- Padding around image
%  - size       -- Size of image
%  - roi        -- Region of interest within data for image
%  - roi_output -- Region to crop output image after transformation
%
% Static methods
%  - simple()      --  propagate the field with a simple interface
%  - simpleProp()  --  construct the propagator for input pattern
%
% See also FftAsmInverse and FftForward.

% Copyright 2023 Institute of Science and Technology Austria
% Written by Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  methods (Static)
    
    function prop = simpleProp(pattern, varargin)
      % Generate the propagator for the specified pattern.
      %
      % prop = simpleProp(pattern, ...) construct a new propagator.
      %
      % Optional named arguemnts:
      %  - axial_offset    num   Offset along the propagation axis
      %    Default: 1.0.  [todo]
      %  - NA         num     Numerical aperture for axial offset lens.
      %    Default: 1.0.  [todo]
      %  - padding  num | [num, num]  Padding for transform.
      %    For details, see FftForward.  Default: ceil(size(pattern)/2)
      %  - trim_padding   bool   if padding should be trimmed from output.
      %    Default: true.
      %  - gpuArray    bool     if we should use the GPU.
      %    Default: isa(pattern, 'gpuArray')
      
      p = inputParser;
      p.addParameter('axial_offset', 1.0);
      p.addParameter('NA', 1.0);
      p.addParameter('padding', ceil(size(pattern)/2));
      p.addParameter('trim_padding', true);
      p.addParameter('gpuArray', isa(pattern, 'gpuArray'));
      p.parse(varargin{:});
      
      % Calculate lens
      lens = otslm.tools.prop.FftBase.calculateLens(...
        size(pattern)+2*p.Results.padding, ...
        p.Results.NA, p.Results.axial_offset);
      
      % Construct propagator
      prop = otslm.tools.prop.FftAsmForward(size(pattern), ...
        'padding', p.Results.padding, ...
        'lens', lens, ...
        'trim_padding', p.Results.trim_padding, ...
        'gpuArray', p.Results.gpuArray);
    end
    
    function [output, prop] = simple(pattern, varargin)
      % propagate the field with a simple interface
      %
      % [output, prop] = simple(pattern, ...) construct a new FFT
      % propagator and apply it to the pattern.  Returns the
      % propagated pattern and the propagator.
      %
      % See also simpleProp for input arguments.
      
      % Construct the propagator
      prop = otslm.tools.prop.FftAsmForward.simpleProp(pattern, varargin{:});
      
      % Apply propagator
      output = prop.propagate(pattern);
    end
  end
  
  methods
    function obj = FftAsmForward(sz, varargin)
      %FFTASMFORWARD Construct a FFT ASM propagator instance
      %
      % FFTFORWARD(sz, ...) construct a new propagator instance
      % for the specified pattern size.  sz must be a 2 element vector.
      %
      % Optional named arguments
      %  - padding    num | [num, num] --  padding to add to edges of
      %    the image.  Either a single number for uniform padding
      %    or two numbers to pass to :func:`padarray`.
      %    Default: ``ceil(sz/2)``
      %
      %  - trim_padding (logical) -- if ``output_roi`` should be set
      %    to remove the padding added before the transform.
      %    Default: false.
      %
      %  - gpuArray (logical) -- if true, allocates memory on the GPU
      %    and does the transform with the GPU instead of the CPU.
      %    Default: false.

      obj = obj@otslm.tools.prop.FftBase(sz, varargin{:});
    end
  end
  
  methods (Access=protected)
    function output = propagate_internal(obj)
      % Apply the forward propagation method

      propagator = obj.lens;
      if isempty(propagator)
          propagator = 1.0;
      end
      
      % Transform to the focal plane (missing scaling factor)
      output = ifft2(fft2(obj.data).*fftshift(propagator));
    end
  end
end
