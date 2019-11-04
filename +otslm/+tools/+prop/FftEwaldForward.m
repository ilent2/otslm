classdef FftEwaldForward < otslm.tools.prop.Fft3Forward ...
    & otslm.tools.prop.EwaldBase
% Propagate using forward Ewald sphere and 3-D FFT
%
% Methods
%  - FftEwaldForward()  -- construct a new propagator instance
%  - propagate()        -- propagate the field
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
% See also FftEwaldInverse, FftForward and otslm.tools.visualise.

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
      %  - diameter    num     Diameter of the lens.
      %    Default: min(size(pattern))
      %
      %  - zsize       num     Depth of the FFT volume.
      %    Default: Calculated from focal_length and diameter
      %
      %  - focal_length  num   Set the focal length of the lens.
      %    Default: diameter/2 (unless NA is set)
      %
      %  - NA          num     Set the focal length via NA.
      %    Default: [] (i.e. defer to focal_length default)
      %
      %  - interpolate   bool   If the Ewald mapping should interpolate.
      %    Default: true.
      %
      %  - padding  num | [xy, z] | [x, y, z]  Padding for transform.
      %    For details, see FftEwaldForward.
      %    Default: ceil([size(pattern), zsize]/2)
      %
      %  - trim_padding   bool   if padding should be trimmed from output.
      %    Default: true.
      %
      %  - gpuArray    bool     if we should use the GPU.
      %    Default: isa(pattern, 'gpuArray')

      p = inputParser;
      p.KeepUnmatched = true;
      p.addParameter('diameter', min(size(pattern)));
      p.addParameter('zsize', []);
      p.addParameter('focal_length', []);
      p.addParameter('NA', []);
      p.addParameter('interpolate', true);
      p.addParameter('padding', []);
      p.addParameter('trim_padding', true);
      p.addParameter('gpuArray', isa(pattern, 'gpuArray'));
      p.parse(varargin{:});
      
      assert(ismatrix(pattern), 'Pattern must be 2-D matrix');
      
      % Get the default diameter of the lens
      diameter = p.Results.diameter;
      
      % Get focal length (from focal_length or NA or default)
      assert(isempty(p.Results.focal_length) || isempty(p.Results.NA), ...
        'Only NA or focal_length should be set, not both');
      focal_length = p.Results.focal_length;
      if isempty(focal_length) && ~isempty(p.Results.NA)
        focal_length = diameter./tan(asin(p.Results.NA)).*2;
      elseif isempty(focal_length)
        focal_length = diameter/2;
      end
      
      % Calculate the depth of the lens volume
      zsize_min = focal_length - sqrt(focal_length.^2 - (diameter/2).^2);
      zsize = p.Results.zsize;
      if isempty(zsize)
        zsize = ceil(zsize_min);
      
        % This method seems to work better if we add a extra padding layer
        zsize = zsize + 2;
      end
      
      % Assemble volume size
      sz = [size(pattern), zsize];
      
      % Handle default padding valid
      padding = p.Results.padding;
      if isempty(padding)
        padding = ceil(sz/2);
      end
      
      % Pass through unmatched parameters
      unmatched = [fieldnames(p.Unmatched).'; struct2cell(p.Unmatched).'];
      
      % Construct propagator
      prop = otslm.tools.prop.FftEwaldForward(sz, unmatched{:}, ...
        'focal_length', focal_length, ...
        'interpolate', p.Results.interpolate, ...
        'padding', padding, ...
        'trim_padding', p.Results.trim_padding, ...
        'gpuArray', p.Results.gpuArray);
    end
    
    function [output, prop] = simple(pattern, varargin)
      % propagate the field with a simple interface
      %
      % [output, prop] = simple(pattern, ...) construct a new
      % propogator and apply it to the pattern.  Returns the
      % propagated pattern and the propagator.
      %
      % See also simpleProp for named arguments.
      
      prop = otslm.tools.prop.FftEwaldForward.simpleProp(pattern, varargin{:});
      
      % Apply propagator
      output = prop.propagate(pattern);
      
    end
  end
  
  methods
    function obj = FftEwaldForward(sz, varargin)
      % Construct a Ewald sphere FFT propagator instance
      %
      % FFTEWALDFORWARD(sz, ...) construct a new propagator instance
      % for the specified pattern size.  sz must be a 3 element vector.
      %
      % Optional named arguments:
      %  - focal_length   num   focal length of the lens in pixels.
      %    Default: min(sz/2).
      %
      %  - interpolate   bool   If the Ewald mapping should interpolate.
      %    Default: true.
      %
      %  - padding    num | [xy, z] | [x, y, z] padding to add to edges of
      %    the image.  Either a single number for uniform padding,
      %    two numbers for separate axial and radial padding,
      %    or three numbers for x, y and z padding.
      %    Default: ceil(sz/2).
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
      p.addParameter('focal_length', min(sz(1:2)/2));
      p.addParameter('interpolate', true);
      p.parse(varargin{:});
      
      % Construct base
      unmatched = [fieldnames(p.Unmatched).'; struct2cell(p.Unmatched).'];
      obj = obj@otslm.tools.prop.Fft3Forward(sz, unmatched{:});
      
      % Store additional parameters
      obj.focal_length = p.Results.focal_length;
      obj.interpolate = p.Results.interpolate;

      % Check the lens is contained in the volume
      xsize = min(sz(1:2));
      zsize_min = obj.focal_length - sqrt(obj.focal_length.^2 - (xsize/2).^2);
      if sz(3) < zsize_min
        warning('otslm:tools:prop:FftEwaldForward:zsize_small', ...
            'Part of lens is not captured by volume size');
      end
    end
    
    function output = propagate(obj, input, varargin)
      % Propogate the input image
      %
      % output = propagate(input, ...) propogates the complex input
      % image by mapping it onto the Ewald sphere and applying 3-D FFT.
      
      assert(ismatrix(input), 'input must be 2-D matrix');
      assert(all(size(input) == obj.size(1:2)), ...
        'input must match Propagator.size(1:2)');
      
      % Map image onto Ewald sphere
      % TODO: We could do this more efficiently by calculating
      %   a mapping lookup table at construction and storing it.
      input = otslm.tools.hologram2volume(input, ...
        'focal_length', obj.focal_length, ...
        'padding', 0, 'interpolate', obj.interpolate, ...
        'zsize', obj.size(3));
      
      output = propagate@otslm.tools.prop.Fft3Forward(...
          obj, input, varargin{:});
    end
  end
end
