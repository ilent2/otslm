function saveVariableToBase(name, pattern, warn_prefix)
% SAVEVARIABLETOBASE saves the variables to the base workspace
%
% saveVariableToBase(name, pattern, warn_prefix)
% Saves the variable pattern to the base workspace with variable name
% `name`.  If name is invalid, prefixes warning with `warn_prefix`.
%
% If the name is empty, aborts the operation.
% If the names is an invalid variable name, raises a warning.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  if nargin < 3
    warn_prefix = 'Name';
  end

  if ~isempty(name)
    if ~isvarname(name)
      warning([warn_prefix, ' must be valid variable name']);
    else
      assignin('base', name, pattern);
    end
  end

end