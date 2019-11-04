classdef Ott2Forward < otslm.tools.prop.OttForward
% Propagate the field using the optical tweezers toolbox.
% Provides a wrapper to calculate the 2-D field after beam calculation.
%
% Requires the optical tweezers toolbox (OTT).
%
% Properties
%  - axis         -- Axis perpendicular to output image plane
%  - offset       -- Offset along axial direction
%  - field        --  Type of field to calculate
%  - output_size  -- Size of the output image
%  - range        -- Range of values to calculate field over
%
% Inherited properties
%  - size         -- Size of input beam image
%  - beam_data    -- Beam with saved data for repeated computations
%  - Nmax         -- Nmax for VSWF
%  - polarisation -- Polarisation of beam (jones vector)
%  - index_medium -- Refractive index in medium
%  - NA           -- Numerical aperture
%  - wavelength0  -- Wavelength in vacuum
%  - omega        -- Angular frequency of light
%
% Static methods
%  - simple()      --  propagate the field with a simple interface
%  - simpleProp()  --  construct the propogator for input pattern
%
% See also OttForward, FftForward and otslm.tools.visualise.

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties
    axis         % Axis perpendicular to output image plane
    offset       % Offset along axial direction
    field        % Type of field to calculate
    output_size  % Size of the output image
    range        % Range of values to calculate field over
  end
  
  methods (Static)
    
    function prop = simpleProp(pattern, varargin)
      % Generate the propagator for the specified pattern.
      %
      % prop = simpleProp(pattern, ...) construct a new propagator.
      %
      % Additional named arguments are passed to Ott2Forward.
      
      prop = otslm.tools.prop.Ott2Forward(size(pattern), varargin{:});
    end
    
    function [output, prop] = simple(pattern, varargin)
      %SIMPLE propagate the field with a simple interface
      %
      % [output, prop] = simple(pattern, ...) propagates the 2-D
      % complex field amplitude `pattern` using the optical tweezers
      % toolbox.  Returns the field in the specified output plane
      % and the propagator.  The propagator contains the OTT.Bsc
      % beam.
      %
      % Additional named arguments are passed to Ott2Forward.
      
      prop = otslm.tools.prop.Ott2Forward.simpleProp(pattern, ...
        varargin{:}, 'pre_calculate', false);
      output = prop.propagate(pattern);
    end
  end
  
  methods
    function obj = Ott2Forward(sz, varargin)
      %OTT2FORWARD Construct a new propagator instance
      %
      % Usage
      %   prop = Ott2Forward(sz, ...) construct a new propagator instance.
      %
      % Parameters
      %   - sz (size) -- size of the pattern in far-field ``[rows, cols]``
      %
      % Optional named arguments
      %  - axis (enum)   --   'x', 'y' or 'z' for axis perpendicular to
      %    image.  Default: z.
      %
      %  - offset (numeric) -- Offset along axial direction.
      %    Default: 0.0.
      %
      %  - field (enum)     --  Field to calculate.
      %    See :func:`+ott.+Bsc.visualise` for a list of valid parameters.
      %    Default: 'irradiance'.
      %
      %  - output_size  [num, num] --  Size of output image.
      %    Default: [80, 80]
      %
      %  - range     [ x, y ]    Range of points to visualise.
      %    Can either be a cell array { x, y }, two scalars for
      %    range [-x, x], [-y, y] or 4 scalars [ x0, x1, y0, y1 ].
      %    Default: []  (parameter is omitted, see ott.Bsc.visualise)
      %
      %  - pre_calculate (logical) -- If beam_data should be set at
      %    construction or at first use of propagate().
      %    Defalut: true

      p = inputParser;
      p.KeepUnmatched = true;
      p.addParameter('axis', 'z');
      p.addParameter('offset', 0.0);
      p.addParameter('field', 'irradiance');
      p.addParameter('output_size', [80, 80]);
      p.addParameter('range', []);
      p.parse(varargin{:});
      
      % Construct the base
      unmatched = [fieldnames(p.Unmatched).'; struct2cell(p.Unmatched).'];
      obj = obj@otslm.tools.prop.OttForward(sz, unmatched{:});
      
      obj.axis = p.Results.axis;
      obj.offset = p.Results.offset;
      obj.field = p.Results.field;
      obj.output_size = p.Results.output_size;
      obj.range = p.Results.range;
    end
    
    function [output, beam] = propagate(obj, input, varargin)
      % Propogate the input image and calculate the ott.Bsc* beam
      %
      % [output, beam] = propagate(input, ...) propogates the complex input
      % image using the optical tweezers toolbox.  Calculates a 2-D
      % image for the output.
      
      % Get the beam
      beam = propagate@otslm.tools.prop.OttForward(obj, input, varargin{:});
      
      % Handle default range parameter value
      range_paramter = {};
      if ~isempty(obj.range)
        range_paramter = {'range', obj.range};
      end
      
      % Run the visualisation
      output = beam.visualise('offset', obj.offset, ...
          'axis', obj.axis, 'field', obj.field, ...
          'size', obj.output_size, range_paramter{:});
    end
  end
end

