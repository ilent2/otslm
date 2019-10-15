function populateDeviceList(list, type_name)
% Populates the device list with Showable devices
%
% Usage
%   populateDeviceList(list) populates the device drop down list
%   with the ``otslm.utils.Showable`` devices in the base workspace.
%
%   populateDeviceList(list, type_name) specify types of devices
%   to populate list with.
%
% Parameters
%   - list (uidropdown) -- List handle to add items to
%   - type_name -- Name of type to filter variables
%     by (optional, default: ``otslm.utils.Showable``)
%
% This function is used to populate the contents of a ``uidropdown``
% widget. The function takes a handle to the ``uidropdown`` widget, an
% optional Matlab class name and searches the base workspace for variables
% with the specified type. If no class name is specified, the method
% populates the list with ``Showable`` object names. For example usage,
% see :class:`ui.simple.linear`.

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
