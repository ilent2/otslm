classdef (Abstract) Showable < handle
% SHOWABLE represents objects that can be used to change the beam (slm/dmds)
%
% Methods (abstract):
%   showRaw(pattern)      Display the pattern on the device.  The pattern
%       is raw values from the device valueRange (i.e. colour mapping
%       should already have been applied).
%
% Methods:
%   show(pattern)         Display the pattern on the device.  The pattern
%       type is determined from the patternType property.
%
%   showComplex(pattern)  Display a complex pattern.  The default
%       behaviour is to call show after converting the pattern
%       to the patternType of the device.  Conversion is done by calling
%       otslm.tools.finalize with for amplitude, phase target.
%
% Properties (abstract):
%   valueRange          Values that the device patterns can contain.
%       This should be a 1-d array, or cell array of 1-d arrays for
%       each dimension of the raw pattern.
%
%   patternType         Type of pattern, can be one of:
%       'phase'             Real pattern in range [0, 1]
%       'amplitude'         Real pattern in range [0, 1]
%       'complex'           Complex pattern, abs(value) <= 1
%
%   size                Size of the device [rows, columns]
%   lookupTable         Lookup table for show -> raw mapping
%
% This is the interface that utility functions which request an
% image from the experiment/simulation use.  For declaring a new
% display device, you should inherit from this class and define
% the abstract methods and properties described above.
% You can also override the other methods if needed.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  methods (Abstract)
    showRaw(obj, pattern)     % Method to show raw pattern
  end

  methods
    function show(obj, pattern)
      % Method to show device type pattern
      %
      % Default behaviour is to apply the colour map and call showRaw.

      pattern = otslm.tools.finalize(pattern, 'colormap', obj.lookupTable);
      obj.showRaw(pattern);
    end

    function showComplex(obj, pattern)
      % Default function to display a complex pattern on a device

      % Split the pattern
      phase = angle(pattern);
      amplitude = abs(pattern);

      % Convert the pattern
      switch patternType
        case 'amplitude'
          pattern = otslm.tools.finalize(phase, 'amplitude', amplitude, ...
              'device', 'dmd', 'rpack', 'none', 'colormap', 'gray');
        case 'phase'
          pattern = otslm.tools.finalize(phase, 'amplitude', amplitude, ...
              'device', 'slm', 'rpack', 'none', 'colormap', 'gray');
        case 'complex'
          % Nothing to do
        otherwise
          error('Unknown pattern type for class');
      end

      % Call the show method to display the function
      obj.show(pattern);
    end
  end

  properties (Abstract, SetAccess=protected)
    valueRange        % Range of values for raw pattern
    lookupTable       % Lookup table for raw values
    patternType       % Type of pattern show() expects
    size              % Size of the device
  end

end
