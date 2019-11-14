classdef (Abstract, HandleCompatible) EwaldBase
% Abstract base class for *Ewald* propagator methods.
%
% Ewald surfaces are described in
%
%   Gal Shabtay, Three-dimensional beam forming and Ewald’s surfaces,
%   Optics Communications, Volume 226, Issues 1–6, 2003, Pages 33-37,
%   https://doi.org/10.1016/j.optcom.2003.07.056.
%
% and
%
%   P.P. Ewald, J. Opt. Soc. Am., 9 (1924), p. 626
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
