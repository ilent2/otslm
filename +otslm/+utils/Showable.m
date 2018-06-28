classdef (Abstract) Showable
% SHOWABLE represents objects that can be used to change the beam (slm/dmds)
%
% Methods (abstract):
%   show(pattern)         Display the pattern on the device.  The pattern
%       type is determined from the patternType property.
%
%   showRaw(pattern)      Display the pattern on the device.  The pattern
%       is raw values from the device valueRange (i.e. colour mapping
%       should already have been applied).
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
%
% This is the interface that utility functions which request an
% image from the experiment/simulation use.  For declaring a new
% display device, you should inherit from this class and define
% the methods and properties described above.

  methods (Abstract)
    show(obj, pattern)        % Method to show device type pattern
    showRaw(obj, pattern)     % Method to show raw pattern
  end

  methods
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
    patternType       % Type of pattern show() expects
  end

end
