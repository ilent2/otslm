classdef (Abstract, HandleCompatible) EwaldBase
% Abstract base class for *Ewald* propagator methods
%
% Properties
%   - focal_length -- focal length of the lens
%   - interpolate  -- if ewald mapping should interpolate
%
% See also :class:`FftForward`, :class:`FftInverse` and
% :func:`otslm.tools.visualise`.

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties (SetAccess=protected)
    focal_length      % Focal length of the lens
    interpolate       % If Ewald mapping should interpolate
  end
end
