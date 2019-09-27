function varargout = unpackCombine(input3, varargin)
%UNPACKCOMBINE Unpack a NxMxK matrix into K NxM matrices
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  input = mat2cell(input3, size(input3, 1), size(input3, 2), ...
    ones(1, size(input3, 3)));
  
  input = squeeze(input);
  
  assignin('base', 'test', input);
  
  [varargout{1:nargout}] = otslm.tools.combine(input, varargin{:});
  
end

