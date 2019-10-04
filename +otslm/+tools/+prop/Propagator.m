classdef Propagator
%PROPAGATOR Base class for field propagation methods
%
% Abstract methods:
%    out = propagate(in, ...) propagates the complex field amplitudes
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.
  
  methods (Abstract)
    propagate(input, varargin)
  end
end

