function im = getImageOrNone(name, silent)
% Get the image from the base workspace or an empty array
%
% Usage
%   im = getImageOrNone(name) gets the variable name from base or None
%   if any error occurs.
%
%   im = getImageOrNone(name, silent) as above but if ``silent=true``
%   does not retrow the error to the console, just silently ignores it.
%
% Parameters
%   - name -- variable name for image in base workspace
%   - silent (logical) -- True if the method should not print warnings
%
% Attempts to evaluate the given string in the base workspace
% with ``evalin``. The string can either be a variable name or valid
% matlab code which can be evaluated in the users base workspace.
%
% If an error occurs, the function prints the error to the console
% and returns a empty matrix. If the silent argument is set to true,
% the function does not print to the console (useful for methods
% which frequently check for the existence of
% a variable, such as :func:`checkImagesChanged`.
% For example usage, see :class:`ui.tools.Visualise`,
% :class:`ui.tools.finalize` and :class:`ui.tools.dither`.

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
