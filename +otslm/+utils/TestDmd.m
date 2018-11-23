classdef TestDmd < otslm.utils.TestShowable
% TESTDMD non-physical dmd-like device for testing code
%
% Properties
%   valueRange    range of raw device values (pixel colours)
%   lookupTable   corresponding phase value for valueRange values
%   patternType   type of pattern for device (phase only device)
%   size          device resolution [rows, columns]
%
%   pattern       pattern currently being displayed
%   incident      Incident illumination profile
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties
    incident        % Incident illumination profile
  end

  properties (SetAccess=protected)
    pattern         % Pattern currently displayed on the device

    valueRange = {0:1};
    lookupTable
    patternType = 'amplitude';
    size            % Size before rotation packing
  end

  methods
    function slm = TestDmd(varargin)
      % Create a new virtual DMD object for testing
      %
      % TestDmd(...) create a virtual binary amplitude device.
      %
      % Optional named arguments:
      %    size      [row, col] Size of the device
      %    incident      im     Incident illumination
      
      % Parse inputs
      p = inputParser;
      p.addParameter('incident', []);
      p.addParameter('size', [512, 512]);
      p.parse(varargin{:});
      
      % Call base constructor
      slm = slm@otslm.utils.TestShowable();
      
      % Store value range and size
      slm.size = p.Results.size;
      
      % Default argument for incident
      if isempty(p.Results.incident)
        slm.incident = ones(slm.size);
      else
        slm.incident = p.Results.incident;
      end
      
      % Default argument for lookup table
      value = slm.linearValueRange('structured', true).';
      slm.lookupTable = otslm.utils.LookupTable(...
          [0; 1], value, 'range', 1);
      
      % Show the device, ensures pattern is initialized
      slm.show();
    end
    
    function showRaw(slm, pattern)
      
      % Handle default argument
      if nargin == 1
        pattern = ones(slm.size);
      end
      
      % Pack pattern with 45 degree rotation
      pattern = otslm.tools.finalize(pattern, 'rpack', '45deg', ...
          'colormap', 'gray', 'modulo', 'none');
      incident = otslm.tools.finalize(slm.incident, 'rpack', '45deg', ...
          'colormap', 'gray', 'modulo', 'none');

      % Make the pattern complex and add incident light
      slm.pattern = complex(pattern .* incident);
    end
    
    function set.incident(slm, newincident)
      % Check the new incident pattern
      assert(all(size(newincident) == slm.size), ...
        'Incident pattern size must match SLM size');
      slm.incident = newincident;
    end
  end

end
