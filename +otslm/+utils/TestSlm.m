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
%   output        resulting pattern in far-field (may move to TestCamera)
%
% See also: otslm.utils.TestCamera
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties (SetAccess=protected)
    pattern       % Pattern currently displayed on the device

    valueRange = {linspace(0, 1, 256).'};
    lookupTable = linspace(0, 1, 256).';
    actualPhaseTable = linspace(0, 2*pi, 256).';
    patternType = 'phase';
    size = [512, 512];
  end

  methods
    
    function obj = TestSlm(actualPhaseTable)
      % Create a new virtual SLM object for testing
      %
      % TestSlm() creates a device with a linear phase table from 0 to 2*pi
      %
      % TestSlm(table) creates a device with a custom phase table.
      % table must contain 256 elements.
      
      if nargin == 0
        actualPhaseTable = linspace(0, 2*pi, 256).';
      end
      
      assert(length(actualPhaseTable) == 256, 'Incorrect table length');
      
      obj = obj@otslm.utils.TestShowable();
      obj.actualPhaseTable = actualPhaseTable(:);
    end
    
    function showRaw(obj, pattern)
      % Simulate the pattern being shown, store result in obj.output
      
      % Check range of raw pattern
      assert(max(pattern(:)) <= max(obj.valueRange{1}) ...
          && min(pattern(:)) >= min(obj.valueRange{1}), ...
          'Raw pattern must not have values outside valueRange');

      % Apply inverse lookupTable
      obj.pattern = interp1(obj.valueRange{1}, double(obj.actualPhaseTable), ...
          pattern(:), 'nearest');
      obj.pattern = reshape(obj.pattern, size(pattern));
      obj.pattern = cast(obj.pattern, 'like', obj.actualPhaseTable);

      % Convert pattern to complex amplitude
      obj.pattern = complex(exp(1i*obj.pattern));
    end
  end

end
