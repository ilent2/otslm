classdef TestSlm < otslm.utils.Showable
% TESTSLM non-physical slm-like device for testing code
%
% Properties:
%   valueRange    range of raw device values (pixel colours)
%   lookupTable   corresponding phase value for valueRange values
%   patternType   type of pattern for device (phase only device)
%   size          device resolution [rows, columns]
%
%   pattern       pattern currently being displayed
%   output        resulting pattern in far-field (may move to TestCamera)
%
% See also: otslm.utils.TestCamera
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties (SetAccess=protected)
    pattern       % Pattern currently displayed on the device
    output        % Resulting pattern in far-field

    valueRange = {linspace(0, 1, 256).'};
    lookupTable = linspace(0, 1, 256).';
    actualPhaseTable = linspace(0, 2*pi, 256).';
    patternType = 'phase';
    size = [512, 512];
  end

  methods
    function showRaw(obj, pattern)
      % Simulate the pattern being shown, store result in obj.output
      obj.pattern = pattern;
      
      % Apply inverse lookupTable
      pattern = otslm.tools.finalize(pattern, ...
          'colormap', {obj.lookupTable, obj.actualPhaseTable});
      
      % Disable range warning (SLM might have larger range)
      oldstate = warning('query', 'otslm:tools:visualise:range');
      warning('off', 'otslm:tools:visualise:range');
      
      obj.output = abs(otslm.tools.visualise(pattern, ...
          'method', 'fft', 'padding', 200)).^2;
        
      % Restore original range warning
      warning(oldstate);
    end
  end

end
