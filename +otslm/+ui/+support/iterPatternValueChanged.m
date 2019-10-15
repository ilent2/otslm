function iterPatternValueChanged(name, pattern, ...
  device_name, enable_update, enable_display, ...
  display_ax, display_type, display_name, fitness_method)
% Common code for iter update uis
%
% Usage
%   iterPatternValueChanged(name, pattern, ...
%   device_name, enable_update, enable_display, ...
%   display_ax, display_type, display_name, fitness_method)
%
% Parameters
%   - name -- Variable name to save pattern in base workspace.
%   - pattern -- Pattern to display/preview
%   - device_name -- Name of Showable device to display pattern on
%   - enable_update -- If showable device should be updated
%   - enable_display -- If preview should be displayed
%   - display_ax -- Axis for preview
%   - display_type -- Type argument for display,
%     see :func:`updateIterDisplay` for options.
%   - display_name -- Output variable name for preview data
%   - fitness_method -- Function handle for fitness graph
%
% This should realy be part of the base class, but we don't seem
% to be able to package apps with a custom base class.  Maybe in
% future MATLAB versions this might be possible.
%
% Function is similar to :func:`simplePatternValueChanged` but with
% a function handle for plotting fitness scores.
%
% See also See also :func:`complexPatternValueChanged` and
% :func:`updateIterDisplay`.

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Save the pattern in the base workspace
otslm.ui.support.saveVariableToBase(name, pattern);

% Display image on the device
slm = otslm.ui.support.getDeviceFromBase(device_name);
if enable_update && ~isempty(slm)
    slm.show(pattern./(2*pi));
end

% Generate display pattern and save to workspace
if enable_display
    otslm.ui.support.updateIterDisplay(pattern, slm, ...
        display_type, display_ax, display_name, fitness_method)
end
