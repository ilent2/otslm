classdef TestDmd < otslm.utils.TestShowable
% TESTDMD non-physical dmd-like device for testing code
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties (SetAccess=protected)
    pattern         % Pattern currently displayed on the device

    valueRange = [ 0, 1 ].';
    lookupTable = [ 0, 1 ].';
    patternType = 'amplitude';
    size = [1024, 512];
  end

  methods
    function showRaw(obj, pattern)
      % Pack pattern with 45 degree rotation
      obj.pattern = otslm.tools.finalize(pattern, 'rpack', '45deg', ...
          'colormap', 'gray');

      % Make the pattern complex
      obj.pattern = complex(obj.pattern);
    end
  end

end
