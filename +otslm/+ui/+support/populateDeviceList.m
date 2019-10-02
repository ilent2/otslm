function populateDeviceList(list, type_name)
% POPULATEDEVICELIST Populates the device list with Showable devices
%
% populateDeviceList(list) populates the device drop down list
% with the otslm.utils.Showable devices in the base workspace.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  if nargin < 2
    type_name = 'otslm.utils.Showable';
  end

  varnames = evalin('base', 'who');
  devices = {};
  for ii = 1:length(varnames)
      if isa(evalin('base', varnames{ii}), type_name)
          devices{end+1} = varnames{ii};
      end
  end
  
  % Populate DropDown with device list
  list.Items = devices;
  list.ItemsData = devices;
  list.Value = '';
  
end