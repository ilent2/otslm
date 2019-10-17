function pattern = castValue(pattern, value)
% Convert from logical pattern to specified value range
%
% Usage
%   pattern = castValue(pattern, value)
%
% Parameters
%   - pattern (logical) -- the pattern to be converted
%   - value (numeric) -- values for logical false and logical true
%     pattern values.  Should be either a 2 element vector
%     ``[false_value, true_value]``.or an empty array to leave the
%     values as logical.

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
