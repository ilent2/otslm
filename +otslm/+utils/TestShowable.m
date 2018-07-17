classdef TestShowable < otslm.utils.Showable
% TESTSHOWABLE non-physical showable device for testing implementation
%
% See also otslm.utils.Showable, otslm.utils.TestSlm and
% otslm.utils.TestCamera.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties (Abstract, SetAccess=protected)
    pattern       % Complex pattern currently displayed on device
  end
end
