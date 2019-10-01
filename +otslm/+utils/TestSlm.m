classdef TestSlm < otslm.utils.TestShowable
% TESTSLM non-physical slm-like device for testing code
%
% Properties:
%   valueRange    range of raw device values (pixel colours)
%   lookupTable   corresponding phase value for valueRange values
%   patternType   type of pattern for device (phase only device)
%   size          device resolution [rows, columns]
%
%   pattern       pattern currently being displayed
%   incident      incident illumination
%
% See also: otslm.utils.TestCamera
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties
    incident                % Incident illumination profile
  end

  properties (SetAccess=protected)
    pattern                 % Pattern currently displayed on the device
    
    valueRange              % Range of values for raw pattern
    lookupTable             % Lookup table for raw values
    patternType = 'phase';  % Type of pattern show() expects
  end
  
  properties (Dependent)
    size                    % Size of the device
  end

  methods
    
    function slm = TestSlm(varargin)
      % Create a new virtual SLM object for testing
      %
      % TestSlm(...) creates a device with a linear phase lookup table
      % from 0 to 2*pi.
      %
      % Optional named arguments:
      %    size      [row, col] Size of the device
      %    incident      im     Incident illumination
      %    lookup_table  tbl    Lookup table for colormap
      %    value_range   cell   Cell array with channel values for raw
      %       pattern.  Default: {0:255}.  Use {0:255, 0:255, 0:255} for
      %       three channel device with 256 levels on each channel.
      
      % Parse inputs
      p = inputParser;
      p.addParameter('lookup_table', []);
      p.addParameter('incident', []);
      p.addParameter('size', [512, 512]);
      p.addParameter('value_range', {0:255});
      p.parse(varargin{:});
      
      % Call base constructor
      slm = slm@otslm.utils.TestShowable();
      
      % Store value range and size
      slm.valueRange = p.Results.value_range;
      our_size = p.Results.size;
      
      % Default argument for incident
      if isempty(p.Results.incident)
        slm.incident = ones(our_size);
      else
        slm.incident = p.Results.incident;
      end
      
      % Default argument for lookup table
      slm.lookupTable = p.Results.lookup_table;
      if isempty(slm.lookupTable)
        value = slm.linearValueRange('structured', true).';
        phase = linspace(0, 2*pi, size(value, 1)).';
        slm.lookupTable = otslm.utils.LookupTable(...
            phase, value, 'range', 2*pi);
      end
      
      % Show the device, ensures pattern is initialized
      slm.show();
    end
    
    function showRaw(slm, pattern)
      % Simulate the pattern being shown, store result in obj.output
      
      % If no work, display a empty screen
      if nargin == 1
        pattern = zeros(slm.size);
      end
      
      % TODO: Support for multi-channel devices
      
      % Apply inverse lookupTable (colormap returns a normalized pattern)
      slm.pattern = otslm.tools.colormap(pattern, slm.lookupTable, 'inverse', true);
      
      % Convert colormap to complex amplitude
      slm.pattern = complex(exp(1i*2*pi*slm.pattern) .* slm.incident);
    end
    
    function set.incident(slm, newincident)
      % Check the new incident pattern
      assert(ismatrix(newincident), 'Incident pattern must be matrix');
      slm.incident = newincident;
    end
    
    function sz = get.size(slm)
      % Get the size of the device (i.e. the incident image)
      sz = size(slm.incident);
    end
  end

end
