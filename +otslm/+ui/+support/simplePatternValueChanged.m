function simplePatternValueChanged(name, pattern, ...
  device_name, enable_update, enable_display, ...
  display_ax, display_type, display_name)
% simplePatternValueChanged common code for simple update uis
%
% This should realy be part of the base class, but we don't seem
% to be able to package apps with a custom base class.  Maybe in
% future MATLAB versions this might be possible.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Save the pattern in the base workspace
otslm.ui.support.saveVariableToBase(name, pattern);

% Display image on the device
slm = otslm.ui.support.getDeviceFromBase(device_name);
if enable_update && ~isempty(slm)
    slm.show(pattern);
end

% Generate display pattern and save to workspace
if enable_display
    otslm.ui.support.updateSimpleDisplay(pattern, slm, ...
        display_type, display_ax, display_name)
end