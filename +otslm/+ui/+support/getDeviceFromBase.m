function slm = getDeviceFromBase(sname)
% Get an showable object from the base workspace
%
% Usage
%  slm = getDeviceFromBase(sname)
%
% Parameters
%  - sname -- string for device variable name in base workspace
%
% Returns
%  Returns the Showable device or an empty list.
%
% This function attempts to get the variable specified by ``sname`` from
% the base workspace. If ``sname`` is empty, the function returns an empty
% matrix. If ``sname`` is not a variable name, the function raises a
% warning. Otherwise, the function gets the variable and checks to see if
% it is valid using ``isvalid``. For example usage see
% :func:`simplePatternValueChanged`.

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
