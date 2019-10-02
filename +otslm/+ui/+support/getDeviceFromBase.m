function slm = getDeviceFromBase(sname)
% getDeviceFromBase get an showable object from the base workspace
%
% If the device is invalid or deleted, displays a warning and
% returns an empty list.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

slm = [];
if ~isempty(sname)
  if ~isvarname(sname)
    warning('Invalid device name specified');
  else
    slm = evalin('base', sname);

    % Validate the handle (make sure its not deleted)
    if ~isvalid(slm)
      warning('Invalid or deleted device');
      slm = [];
    end
  end
end