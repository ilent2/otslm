function simplePatternValueChanged(name, pattern, ...
  device_name, enable_update, enable_display, ...
  display_ax, display_type, display_name)
% Common code for simple update uis
%
% Usage
%   simplePatternValueChanged(name, pattern, ...
%   device_name, enable_update, enable_display, ...
%   display_ax, display_type, display_name)
%
% Parameters
%   - name -- Variable name to save pattern in base workspace.
%   - pattern -- Pattern to save/preview/display
%   - device_name -- Name of Showable device to display pattern on
%   - enable_update -- If showable device should be updated
%   - enable_display -- If preview should be displayed
%   - display_ax -- Axis for preview
%   - display_type -- Type argument for display,
%     see :func:`updateSimpleDisplay` for options.
%   - display_name -- Output variable name for preview data
%
% This should realy be part of the base class, but we don't seem
% to be able to package apps with a custom base class.  Maybe in
% future MATLAB versions this might be possible.
%
% This function is used by most of the simple GUIs including
% ``ui.simple.linear``, ``ui.simple.random``, and ``ui.tools.combine``.
% The function takes as input values from the various GUI components as
% well as the generated pattern. The function saves the pattern to the
% workspace, displays the pattern on the device, and updates the pattern
% preview (if the appropriate values are set).
%
% See also :func:`iterPatternValueChanged` and
% :func:`complexPatternValueChanged`.

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
