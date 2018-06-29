classdef TestDmd < otslm.utils.Showable
% TestDmd non-physical dmd-like device for testing code
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties (SetAccess=protected)
    pattern         % Pattern currently displayed on the device
    output          % Resulting pattern in far-field

    valueRange = [ 0, 1 ].';
    lookupTable = [ 0, 1 ].';
    patternType = 'amplitude';
    size = [1024, 512];
  end

  methods
    function showRaw(obj, pattern)
      % Simulate the pattern being shown, store result in obj.output
      obj.pattern = pattern;

      % Pack pattern with 45 degree rotation
      pattern = otslm.tools.finalize(pattern, 'rpack', '45deg', ...
          'colormap', 'gray');

      % Simulate output
      obj.output = abs(otslm.tools.visualise(zeros(size(pattern)), ...
          'amplitude', pattern, 'method', 'fft')).^2;
    end
  end

end
