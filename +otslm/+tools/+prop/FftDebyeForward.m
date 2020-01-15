classdef FftDebyeForward < otslm.tools.prop.FftForward
% Propagate using forward 2-D FFT formulation of Debye integral.
% Inherits from :class:`FftForward`.
%
% This method is useful for simulating focusing of paraxial fields
% by high numerical aperture (NA) objectives.  The method accounts for
% some of the polarisation and phase affects present in high NA focussing.
%
% The method and conditions for obtaining acurate results are
% described in
%
%   M. Leutenegger, et al., Fast focus field calculations,
%   Optics Express Vol. 14, Issue 23, pp. 11277-11291 (2006)
%   https://doi.org/10.1364/OE.14.011277
%
% Methods
%  - FftForward()  --  construct a new propagator instance
%  - propagate()   --  propagate the field forward using 2-D FFT
%
% Properties
%  - NA         -- Numerical aperture of lens
%  - radius     -- Radius of lens
%  - polarisation -- Default polarisation for scalar input to propagate
%
% Properties (inherited)
%  - data       -- Memory allocated for transform input
%  - lens       -- Lens to be applied before transformation
%  - padding    -- Padding around image
%  - size       -- Size of image
%  - roi        -- Region of interest within data for image
%  - roi_output -- Region to crop output image after transformation
%
% Static methods
%  - simple()      --  propagate the field with a simple interface
%  - simpleProp()  --  construct the propagator for input pattern
%  - calculateLens() -- generates the lens required by the method
%
% See also FftForward, Fft3Forward and OttForward

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  methods (Static)

    function lens = calculateLens(sz, NA, radius, z)
      % Calculate lens function for FftDebyeForward.
      %
      % The lens function is given by
      %
      % .. math:
      %
      %   \exp{2\pi i \cos\theta z}
      %
      % where :math:`\theta = \arcsin(r)` and :math:`r` is the normalized
      % radius of the lens.
      %
      % Usage
      %   lens = calculateLens(sz, NA, radius, z)
      %
      % Parameters
      %   - sz (size) -- Size of the pattern ``[rows, cols]``.
      %   - NA (numeric) -- Numerical aperture of lens.
      %     Assumes medium has refractive index of 1.  NA should be
      %     adjusted if medium has different refractive index (NA/n_medium).
      %   - radius (numeric) -- Radial scaling factor for lens.
      %     (units: pixels).
      %   - z (numeric) -- Axial offset (units: inverse wavelength
      %     in medium).

      if z ~= 0
        % Equation 11
        [~, ~, rr] = otslm.simple.grid(sz);
        theta = asin(NA.*rr./abs(radius));

        % Based on equation 12
        lens = exp(1i*2*pi*cos(theta)*z);

        % Remove parts outside lens
        lens(rr >= radius) = 0;
      else
        lens = [];
      end
    end

    function prop = simpleProp(pattern, varargin)
      % Generate the propagator for the specified pattern.
      %
      % prop = simpleProp(pattern, ...) construct a new propagator.
      %
      % Optional named arguments:
      %  - polarisation  [num, num]  -- X and Y polarisation to use
      %    when :meth:`propagate` is called with only a single argument.
      %    Default: ``[1.0, 0.0]``.
      %
      %  - axial_offset    num   Offset along the propagation axis
      %    Default: 0.0.
      %
      %  - NA         num     Numerical aperture for axial offset lens.
      %    Default: 1.0.
      %
      %  - radius (numeric) -- Radius of lens.
      %    Default: ``min(size(pattern))/2``.
      %
      %  - padding  num | [num, num]  Padding for transform.
      %    For details, see FftForward.  Default: ceil(size(pattern)/2)
      %
      %  - trim_padding   bool   if padding should be trimmed from output.
      %    Default: true.
      %
      %  - gpuArray    bool     if we should use the GPU.
      %    Default: isa(pattern, 'gpuArray')

      p = inputParser;
      p.addParameter('polarisation', [1, 0]);
      p.addParameter('axial_offset', 0.0);
      p.addParameter('NA', 1.0);
      p.addParameter('radius', min(size(pattern)/2));
      p.addParameter('padding', ceil(size(pattern)/2));
      p.addParameter('trim_padding', true);
      p.addParameter('gpuArray', isa(pattern, 'gpuArray'));
      p.parse(varargin{:});

      % Calculate lens
      lens = otslm.tools.prop.FftDebyeForward.calculateLens(...
        size(pattern)+2*p.Results.padding, ...
        p.Results.NA, p.Results.radius, p.Results.axial_offset);

      % Construct propagator
      prop = otslm.tools.prop.FftDebyeForward(size(pattern), ...
        'polarisation', p.Results.polarisation, ...
        'radius', p.Results.radius, ...
        'NA', p.Results.NA, ...
        'padding', p.Results.padding, ...
        'trim_padding', p.Results.trim_padding, ...
        'lens', lens, ...
        'gpuArray', p.Results.gpuArray);
    end

		function [output, prop] = simple(pattern, varargin)
      % propagate the field with a simple interface
      %
      % [output, prop] = simple(pattern, ...) construct a new FftDebye
      % propagator and apply it to the pattern.  Returns the
      % propagated pattern and the propagator.
      %
      % See also :meth:`simpleProp` for input arguments.

      % Construct the propagator
      prop = otslm.tools.prop.FftDebyeForward.simpleProp(pattern, varargin{:});

      % Apply propagator
      output = prop.propagate(pattern);
		end
  end

  properties
    polarisation         % Default polarisation for scalar inputs
    NA                   % Numerical aperture of lens
    radius               % Radius of lens
  end

  methods
    function obj = FftDebyeForward(sz, varargin)
      % Construct a FFT Debye forward propagator instance.
      %
      % Usage
      %   obj = FftDebyeForward(sz, ...) construct a new propagator
      %   instance for the specified pattern size.  sz must be a 2
      %   element vector.
      %
      % Optional named arguments
      %  - polarisation  [num, num]  -- X and Y polarisation to use
      %    when :meth:`propagate` is called with only a single argument.
      %    Default: ``[1.0, 0.0]``.
      %
      %  - NA (numeric)    -- Numerical aperture for axial offset lens.
      %    Default: 1.0.
      %
      %  - radius (numeric) -- Radius of lens.
      %    Default: ``min(sz)/2``.
      %
      %  - padding    num | [num, num] --  padding to add to edges of
      %    the image.  Either a single number for uniform padding
      %    or two numbers to pass to :func:`padarray`.
      %    Default: ``ceil(sz/2)``
      %
      %  - lens (complex)      --  lens pattern to add to the transform.
      %    This should typically be a result of :meth:`calculateLens`.
      %    Pattern should have same size as sz + padding.
      %    The lens function should be a complex field amplitude.
      %    Default: ``[]``.
      %
      %  - trim_padding (logical) -- if ``output_roi`` should be set
      %    to remove the padding added before the transform.
      %    Default: false.
      %
      %  - gpuArray (logical) -- if true, allocates memory on the GPU
      %    and does the transform with the GPU instead of the CPU.
      %    Default: false.

      % Parse inputs
      p = inputParser;
      p.KeepUnmatched = true;
      p.addParameter('radius', min(sz/2));
      p.addParameter('NA', 1.0);
      p.addParameter('polarisation', [1, 0]);
      p.parse(varargin{:});

      % Call base class for most handling
      unmatched = [fieldnames(p.Unmatched).'; struct2cell(p.Unmatched).'];
      obj = obj@otslm.tools.prop.FftForward(sz, unmatched{:});

      % Store remaining properties
      obj.polarisation = p.Results.polarisation;
      obj.NA = p.Results.NA;
      obj.radius = p.Results.radius;
    end

    function obj = set.NA(obj, val)
      % Check inputs
      assert(isnumeric(val) && numel(val) == 1, ...
          'NA must be numeric scalar');
      obj.NA = val;
    end

    function obj = set.radius(obj, val)
      % Check inputs
      assert(isnumeric(val) && numel(val) == 1, ...
          'NA must be numeric scalar');
      obj.radius = val;
    end

    function obj = set.polarisation(obj, val)
      % Check inputs
      assert(isnumeric(val) && numel(val) == 2, ...
          'Polarisation must be 2 element numeric vector');
      obj.polarisation = val;
    end

    function output = propagate(obj, input, varargin)
      % Propagate the input image
      %
      % Usage
      %   output = propagate(input, ...) propagates the complex input
      %   image using 2-D FFT formulation of the Debye integral.
      %   Returns a NxMx3 matrix for the complex vector field at the focus.
      %
      % Parameters
      %   - input (numeric) -- paraxial far-field image.
      %     Should either be a NxM or NxMx2 matrix.
      %     If the matrix is single channel, the method ``polarisation``
      %     property is used.
      
      % Make sure the direction matches the direction in FftForward
      input = conj(input);

      output = propagate@otslm.tools.prop.FftBase(obj, input);
    end
  end

  methods (Access=protected)
    function insertInput(obj, input)
      % Insert the input image into ``data``
      %
      % Usage
      %   obj.insertInput(input)
      %
      % Parameters
      %   - input (numeric) -- paraxial far-field image.
      %     Should either be a NxM or NxMx2 matrix.
      %     If the matrix is single channel, the method ``polarisation``
      %     property is used.

      % Convert input the MxNx2
      if size(input, 3) == 1
        input(:, :, 2) = input .* obj.polarisation(2);
        input(:, :, 1) = input(:, :, 1) .* obj.polarisation(1);
      elseif size(input, 3) ~= 2
        error('input must be NxM or NxMx2 matrix');
      end

      % Calculate theta and phi
      [~, ~, rr, phi] = otslm.simple.grid(obj.size);
      theta = asin(obj.NA.*rr./obj.radius);

      ep = cos(phi);
      ep(:, :, 2) = sin(phi);

      es = -sin(phi);
      es(:, :, 2) = cos(phi);

      es3 = es;
      es3(:, :, 3) = 0;

      et = cos(phi).*cos(theta);
      et(:, :, 2) = sin(phi).*cos(theta);
      et(:, :, 3) = sin(theta);

      E = dot(input, ep, 3).*et + dot(input, es, 3).*es3;

      E = E ./ cos(theta);
      
      % Remove light outside aperture
      E(repmat(rr >= obj.radius, 1, 1, 3)) = 0;

      % Assign data
      obj.data(obj.roi(2)-1 + (1:obj.roi(4)), ...
            obj.roi(1)-1 + (1:obj.roi(3)), :) = E;
    end

    function allocateData(obj, total_sz, useGpuArray)
      % Allocate a 3 channel image for the x, y and z components

      if useGpuArray
        obj.data = gpuArray.zeros([total_sz, 3]);
      else
        obj.data = zeros([total_sz, 3]);
      end
    end
  end
end

