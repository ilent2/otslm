classdef RsForward < otslm.tools.prop.Propagator
% Propagate the field forward using Rayleight-Sommerfeld integral
%
% Properties
%  - size     -- Size of the pattern
%  - distance -- Distance to propagate pattern
%
% Static methods
%  - simple()      --  propagate the field with a simple interface
%  - simpleProp()  --  construct the propagator for input pattern
%
% See also FftForward, OttForward and otslm.tools.visualise.

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  % TODO: Implement RS with exp(-i*omega) for inverse transform
  % TODO: This runs really slowly on a CPU, but perhaps we can
  %   do GPU-mex and get it to run reasonably on a GPU.
  % TODO: HotLab does Fresnel summation, how is this different
  %   from Rayleigh-Sommerfeld, could we do this with GPU-mex?
  
  properties (SetAccess=protected)
    size        % Size of input pattern
  end
  
  properties
    distance    % Distance to propagate pattern
  end
  
  methods (Static)
    
    function prop = simpleProp(pattern, distance, varargin)
      % Generate the propagator for the specified pattern.
      %
      % prop = simpleProp(pattern, ...) construct a new propagator.
      %
      % See also simple and RsForward.
      
      prop = otslm.tools.prop.RsForward(size(pattern), distance, varargin{:});
    end
    
    function [output, prop] = simple(pattern, distance, varargin)
      %SIMPLE propagate the field with a simple interface
      %
      % output = simple(pattern, distance, ...) propagates the 2-D
      % complex field amplitude `pattern` using the Rayleigh-Sommerfeld
      % integral by the specified distance.
      %
      % See also simple and RsForward.
      
      prop = otslm.tools.prop.RsForward.simpleProp(...
        pattern, distance, varargin{:});
      
      output = prop.propagate(pattern);
    end
  end
  
  methods
    function obj = RsForward(sz, distance, varargin)
      %RSFORWARD Construct a new propagator instance
      %
      % obj = RsForward(sz, distance, ...) construct a propagator
      % instance for the specified image size and propagation distance.
      % distance must be a scalar, sz must be a 2 element vector.
      
      p = inputParser;
      p.parse(varargin{:});
      
      obj = obj@otslm.tools.prop.Propagator();
      
      obj.size = sz;
      obj.distance = distance;
      
      % Check for a compiler
      ccs = mex.getCompilerConfigurations('C++');
      assert(~isempty(ccs), 'No C++ compilers installed');

      % Check for a compiled mex file
      % This feels like a little bit of kludge (wasn't there a better way?)
      if exist('+otslm\+tools\+prop\vis_rsmethod.mexw64', 'file') == 0
        warning('No mex file found, compiling mex file');
        [toolpath, ~, ~] = fileparts(mfilename('fullpath'));
        mex('-R2018a', [toolpath, '\vis_rsmethod.cpp'], '-outdir', toolpath);
      end
      
    end
    
    function output = propagate(obj, input, varargin)
      % Propogate the input image
      %
      % [output, beam] = propagate(input, ...) propogates the complex input
      % image using the Rayleigh-Sommerfeld integral.
      
      scale = 1;                % Number of pixels in output
      uscale = 1;               % Upscaling of input input image
      pixelsize = [20, 20];     % Pixel size in units of wavelength

      % Repeat elements for multi-sampling
      input = repelem(input, uscale, uscale);

      output = otslm.tools.prop.vis_rsmethod(input, ...
        pixelsize, obj.distance, scale*uscale);
      
    end
    
    function obj = set.size(obj, val)
      % Check size parameter
      assert(numel(val) == 2, 'size must be 2 element vector');
      obj.size = val;
    end
    
    function obj = set.distance(obj, val)
      % Check size parameter
      assert(isscalar(val), 'distance must be scalar');
      obj.distance = val;
    end
  end
end

