function varargout = unpackCombine(input3, varargin)
%UNPACKCOMBINE Unpack a NxMxK matrix into K NxM matrices

  input = mat2cell(input3, size(input3, 1), size(input3, 2), ...
    ones(1, size(input3, 3)));

  input = squeeze(input);
  
  [varargout{1:nargout}] = otslm.tools.combine(input, varargin{:});
  
end

