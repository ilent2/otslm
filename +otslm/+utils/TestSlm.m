classdef TestSlm < otslm.utils.Showable
% TestSlm non-physical slm-like device for testing code
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties (SetAccess=protected)
    pattern       % Pattern currently displayed on the device
    output        % Resulting pattern in far-field

    valueRange = linspace(0, 1, 256).';
    lookupTable = linspace(-pi, pi, 256).';
    patternType = 'phase';
    size = [512, 512];
  end

  methods
    function showRaw(obj, pattern)
      % Simulate the pattern being shown, store result in obj.output
      obj.pattern = pattern;
      obj.output = abs(otslm.tools.visualise(pattern, 'method', 'fft')).^2;
    end
  end

end
