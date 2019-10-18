classdef TestShowable < otslm.utils.Showable
% Non-physical showable device for testing implementation.
% Inherits from :class:`Showable`.
%
% This is an abstract class defining a single abstract property,
% ``pattern``, containing the pattern currently displayed on the device.
% For implementations see :class:`TestDmd` and :class:`TestSlm`.
%
% Properties (Abstract)
%   - pattern -- complex valued pattern currently displayed on the device.
%
% See also :class:`Showable`, :class:`TestSlm` and :class:`TestCamera`.

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties (Abstract, SetAccess=protected)
    pattern       % Complex pattern currently displayed on device
  end
end
