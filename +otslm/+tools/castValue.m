function pattern = castValue(pattern, value)
% castValue convert from logical pattern to specified value range
%
% pattern = castValue(pattern, [min, max]) converts from a logical
% pattern to the specified value range.  If [min, max] isan empty
% array, leaves the pattern as a logical array.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  if ~isempty(value)

    assert(numel(value) == 2, 'Length of value must be 2');

    high = value(2);
    low = value(1);
    pattern = pattern .* (high - low) + low;

    % Ensure type of output matches low/high
    pattern = cast(pattern, class(value));
  end

end