classdef Propagator < handle
% Base class for field propagation methods.
%
% Inherits from handle.  This means that we can reuse the data block
% through multiple calls to propagate and easily split our code up
% into separate overload-able functions.
%
% Abstract methods:
%    out = propagate(in, ...) propagates the complex field amplitudes

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  methods (Abstract)
    propagate(input, varargin)
  end
end

