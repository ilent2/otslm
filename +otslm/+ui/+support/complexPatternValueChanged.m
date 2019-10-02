function complexPatternValueChanged(name, phase, amplitude, ptype, ...
  device_name, enable_update, enable_display, ...
  display_ax, display_type, display_name)
% simplePatternValueChanged common code for simple update uis with ptype
%
% This should realy be part of the base class, but we don't seem
% to be able to package apps with a custom base class.  Maybe in
% future MATLAB versions this might be possible.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.
            
% Generate the desired output pattern type
switch ptype
    case 'phase'
        pattern = phase;
    case 'amplitude'
        pattern = amplitude;
    case 'complex'
        pattern = abs(amplitude).*exp(2*pi*1i*phase + 1i*pi);
    otherwise
        error('Invalid drop down value');
end

% Save the pattern in the base workspace
otslm.ui.support.saveVariableToBase(name, pattern);

% Display image on the device
slm = otslm.ui.support.getDeviceFromBase(device_name);
if enable_update && ~isempty(slm)
    if strcmpi(ptype, 'complex')
        slm.showComplex(pattern);
    else
        slm.show(pattern);
    end
end

% Generate display pattern
if enable_display
    otslm.ui.support.updateComplexDisplay(pattern, slm, ptype, ...
        display_type, display_ax, display_name)
end