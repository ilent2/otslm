function im = getImageOrNone(name, silent)
% Get the image from the base workspace or an empty array
%
% im = getImageOrNone(name) gets the variable name from base or None
% if any error occurs.
%
% Uses evalin to get the variable name from the base.
% If an error occurs, rethrows the error as a warning.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

if nargin < 2
  silent = false;
end

if isempty(name)
    im = [];
else
  try
    im = evalin('base', name);
  catch ME
    if ~silent
      disp(getReport(ME, 'extended', 'hyperlinks', 'on'));
    end
    im = [];
  end
end
