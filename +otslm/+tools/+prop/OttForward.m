classdef OttForward < otslm.tools.prop.Propagator
%OTTFORWARD Propagate the field using the optical tweezers toolbox
%
% Properties:
%    size           Size of input beam image
%    beam_data      Beam with saved data for repeated computations
%    Nmax           Nmax for VSWF
%    polarisation   Polarisation of beam (jones vector)
%    index_medium   Refractive index in medium
%    NA             Numerical aperture
%    wavelength0    Wavelength in vacuum
%    omega          Angular frequency of light
%
% Static methods:
%    simple()        propagate the field with a simple interface
%    simpleProp()    construct the propogator for input pattern
%
% See also Ott2Forward, Ott3Forward and otslm.tools.visualise.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.
  
  properties (SetAccess=protected)
    size          % Size of input beam image
    beam_data     % Beam with saved data for faster future computations
    
    Nmax          % Nmax for VSWF
    polarisation  % Polarisation of beam (jones vector)
    index_medium  % Refractive index in medium
    NA            % Numerical aperture
    wavelength0   % Wavelength in vacuum
    omega         % Angular frequency of light
  end
  
  methods (Static)
    
    function prop = simpleProp(pattern, varargin)
      % Generate the propagator for the specified pattern.
      %
      % prop = simpleProp(pattern, ...) construct a new propagator.
      %
      % Additional named arguments are passed to Ott2Forward.
      
      prop = otslm.tools.prop.OttForward(size(pattern), varargin{:});
      
    end
    
    function [beam, prop] = simple(pattern, varargin)
      %SIMPLE propagate the field with a simple interface
      %
      % [output, prop] = simple(pattern, ...) propagates the 2-D
      % complex field amplitude `pattern` using the optical tweezers
      % toolbox.  Returns the beam and the propagator.
      %
      % Additional named arguments are passed to Ott2Forward.
      
      prop = otslm.tools.prop.OttForward.simpleProp(pattern, ...
        varargin{:}, 'pre_calculate', false);
      
      beam = prop.propagate(pattern);
    end
  end
  
  methods
    function obj = OttForward(sz, varargin)
      %OTTFORWARD Construct a new propagator instance
      %
      % prop = OttForward(sz, ...) construct a new propagator instance.
      % sz must be a 2 element vector for the far-field size.
      %
      % Optional named arguments:
      %    pre_calculate   bool   If beam_data should be set at
      %       construction or at first use of propagate().
      %       Defalut: true
      %
      %    beam_data     ott.Bsc  Beam object to use instead of
      %       calculating the VSWF expansion.  Incompatible with
      %       pre_calculate.   Default: []
      %
      %   Nmax         num      The VSWF truncation number
      %   polarisation [x,y]    Polarisation of the VSWF beam
      %   index_medium num      Refractive index of medium
      %   NA           num      Numerical aperture of objective
      %   wavelength0  num      Wavelength of light in vacuum (default: 1)
      %   omega        num      Angular frequency of light (default: 2*pi)
      
      p = inputParser;
      p.addParameter('Nmax', 20);
      p.addParameter('polarisation', [1, 1i]);
      p.addParameter('index_medium', 1.0);
      p.addParameter('NA', 0.9);
      p.addParameter('wavelength0', 1.0);
      p.addParameter('omega', 2*pi);
      p.addParameter('beam_data', []);
      p.addParameter('pre_calculate', true);
      p.parse(varargin{:});
      
      obj = obj@otslm.tools.prop.Propagator();
      obj.size = sz;
      obj.Nmax = p.Results.Nmax;
      obj.polarisation = p.Results.polarisation;
      obj.index_medium = p.Results.index_medium;
      obj.NA = p.Results.NA;
      obj.wavelength0 = p.Results.wavelength0;
      obj.omega = p.Results.omega;
      obj.beam_data = p.Results.beam_data;
      
      % If required, pre-calculate beam data
      if p.Results.pre_calculate && isempty(obj.beam_data)
        input = zeros(obj.size);
        obj.beam_data = otslm.tools.hologram2bsc(input, ...
            'Nmax', obj.Nmax, 'polarisation', obj.polarisation, ...
            'index_medium', obj.index_medium, 'NA', obj.NA, ...
            'wavelength0', obj.wavelength0, 'omega', obj.omega, ...
            'keep_coefficient_matrix', true);
      end
    end
    
    function beam = propagate(obj, input, varargin)
      % Propogate the input image and calculate the ott.Bsc* beam
      %
      % output = propagate(input, ...) propogates the complex input
      % image using the optical tweezers toolbox.
      
      assert(all(size(input) == obj.size), ...
        'input must match Propagator.size');
      
      beam = otslm.tools.hologram2bsc(input, ...
        'Nmax', obj.Nmax, 'polarisation', obj.polarisation, ...
        'index_medium', obj.index_medium, 'NA', obj.NA, ...
        'wavelength0', obj.wavelength0, 'omega', obj.omega, ...
        'beamData', obj.beam_data, ...
        'keep_coefficient_matrix', isempty(obj.beam_data));
      
      % If we haven't already set it, set it now
      if isempty(obj.beam_data)
        obj.beam_data = beam;
      end
    end
  end
end

