classdef FftEwaldInverse < otslm.tools.prop.Fft3Inverse ...
    & otslm.tools.prop.EwaldBase
% Propagate using inverse Ewald sphere and 3-D FFT.
% Inherits from :class:`EwaldBase` and :class:`Fft3Inverse`.
%
% Ewald surfaces are described in
%
%   Gal Shabtay, Three-dimensional beam forming and Ewald surfaces,
%   Optics Communications, Volume 226, Issues 16, 2003, Pages 33-37,
%   https://doi.org/10.1016/j.optcom.2003.07.056.
%
% and
%
%   P.P. Ewald, J. Opt. Soc. Am., 9 (1924), p. 626
%
% Methods
%  - FftEwaldInverse() -- construct a new propagator instance
%  - propagate()       -- propagate the field
%
% Properties
%  - data        -- Memory allocated for transform input (3-D)
%  - padding     -- Padding around image [x, y, z]
%  - size        -- Size of image [x, y, z]
%  - roi         -- Region of interest within data for image
%  - roi_output  -- Region to crop output image after transformation
%  - focal_length -- Focal length of the lens
%
% Static methods
%  - simple()       -- propagate the field with a simple interface
%  - simpleProp()   -- construct the propagator for input pattern
%
% See also FftEwaldForward, FftInverse and otslm.tools.visualise.

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
      %  - padding   num | [xy, z] | [x, y, z]  Padding for transform.
      %    For details, see :meth:`FftEwaldInverse`.
      %    Default: ``ceil(size(pattern)/2)``
      %
      %  - trim_padding   bool   if padding should be trimmed from output.
      %    Default: true.
      %
      %  - gpuArray    bool     if we should use the GPU.
      %    Default: isa(pattern, 'gpuArray')

      p = inputParser;
      p.addParameter('diameter', min([size(pattern, 1), size(pattern, 2)]));
      p.addParameter('focal_length', []);
      p.addParameter('NA', []);
      p.addParameter('interpolate', true);
      p.addParameter('padding', ceil(size(pattern)/2));
      p.addParameter('trim_padding', true);
      p.addParameter('gpuArray', isa(pattern, 'gpuArray'));
      p.parse(varargin{:});

      % Get the default diameter of the lens
      diameter = p.Results.diameter;

      % Get focal length (from focal_length or NA or default)
      assert(isempty(p.Results.focal_length) || isempty(p.Results.NA), ...
        'Only NA or focal_length should be set, not both');
      focal_length = p.Results.focal_length;
      if isempty(focal_length) && ~isempty(p.Results.NA)
        focal_length = diameter./tan(asin(p.Results.NA)).*2;
      elseif isempty(focal_length)
        zsize = size(pattern, 3);
        
        % This method seems to work better if we add a extra padding layer
        zsize = zsize - 2;
      
        focal_length = ((diameter/2).^2 + zsize.^2)/(2*zsize);
      end
      
      % Construct propagator
      prop = otslm.tools.prop.FftEwaldInverse(size(pattern), ...
        'interpolate', p.Results.interpolate, ...
        'focal_length', focal_length, ...
        'padding', p.Results.padding, ...
        'trim_padding', p.Results.trim_padding, ...
        'gpuArray', p.Results.gpuArray);
    end
    
    function [output, prop] = simple(pattern, varargin)
      % propagate the field with a simple interface
      %
      % [output, prop] = simple(pattern, ...) construct a new Ewald FFT
      % propogator and apply it to the pattern.  Returns the
      % propagated pattern and the propagator.
      %
      % See also simpleProp for named arguments.
      
      prop = otslm.tools.prop.FftEwaldInverse.simpleProp(pattern, varargin{:});
      
      % Apply propagator
      output = prop.propagate(pattern);
      
    end
  end
  
  methods
    function obj = FftEwaldInverse(sz, varargin)
      % Construct a Ewald inverse FFT propagator instance.
      %
      % FFTEWALDINVERSE(sz, ...) construct a new propagator instance
      % for the specified pattern size.  sz must be a 3 element vector.
      %
      % Optional named arguments:
      %  - focal_length   num   focal length of the lens in pixels.
      %    Default: ``((min(sz(1:2))/2).^2 + sz(3).^2)/(2*sz(3))``
      %
      %  - interpolate   bool   If the Ewald mapping should interpolate.
      %    Default: true.
      %
      %  - padding    num | [xy, z] | [x, y, z] padding to add to edges of
      %    the image.  Either a single number for uniform padding,
      %    two numbers for separate axial and radial padding,
      %    or three numbers for x, y and z padding.
      %    Default: ``ceil(sz/2)``
      %
      %  - trim_padding (logical) -- if the output_roi should be set
      %    to remove the padding added before the transform.
      %    Default: false.
      %
      %  - gpuArray (logical) -- if true, allocates memory on the GPU
      %    and does the transform with the GPU instead of the CPU.
      %    Default: false.

      p = inputParser;
      p.KeepUnmatched = true;
      p.addParameter('focal_length', ...
        ((min(sz(1:2))/2).^2 + sz(3).^2)/(2*sz(3)));
      p.addParameter('interpolate', true);
      p.parse(varargin{:});
      
      % Construct base
      unmatched = [fieldnames(p.Unmatched).'; struct2cell(p.Unmatched).'];
      obj = obj@otslm.tools.prop.Fft3Inverse(sz, unmatched{:});
      
      % Store additional parameters
      obj.focal_length = p.Results.focal_length;
      obj.interpolate = p.Results.interpolate;
    end
    
    function output = propagate(obj, input, varargin)
      % Propogate the input image
      %
      % output = propagate(input, ...) propogates the complex input
      % image by appying 3-D iFFT and unmapping the Ewald sphere.
      
      assert(ndims(input) == 3, 'input must be 3-D matrix');
      assert(all(size(input) == obj.size), ...
        'input must match Propagator.size');
      
      % Apply inverse fft with base
%       output = propagate@otslm.tools.prop.Fft3Inverse(...
%           obj, input, varargin{:});
      
      % Inverse map volume Ewald sphere to image
      % TODO: We could do this more efficiently by calculating
      %   a mapping lookup table at construction and storing it.
%       output = otslm.tools.volume2hologram(output, ...
%         'focal_length', obj.focal_length, ...
%         'padding', 0, 'interpolate', obj.interpolate);
        

      % The above didn't seem to work very well, the following
      % works well for simple tests but is is probably fragile
      % and may not give the correct results in some cases.
      
      % Copy input into padded array
      obj.data(obj.roi(2)-1 + (1:obj.roi(5)), ...
        obj.roi(1)-1 + (1:obj.roi(4)), ...
        obj.roi(3)-1 + (1:obj.roi(6))) = input;
      
      output = obj.propagate_internal();

      % Seems there can be a lot of bluring, this seems to work
      % better at least on the forward-inverse test
      % TODO: What is the best choice?
%       output = sum(output(:, :, 1:end/2), 3);
      output = sum(output, 3);
      
      % Remove padding if requested
      if ~isempty(obj.roi_output)
        output = output(obj.roi_output(2)-1 + (1:obj.roi_output(5)), ...
            obj.roi_output(1)-1 + (1:obj.roi_output(4)));
      end

    end
  end
end
