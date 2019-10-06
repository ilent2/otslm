classdef (Abstract) EwaldBase
%EWALDBASE Abstract base class for *Ewald* propagator methods
%
% Properties:
%
% See also FftForward, FftInverse and otslm.tools.visualise.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.
  
  properties (SetAccess=protected)
    focal_length      % Focal length of the lens
    interpolate       % If Ewald mapping should interpolate
  end
end