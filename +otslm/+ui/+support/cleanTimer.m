function cleanTimer(tmr)
% Cleans up the timer when the app is about to finish
%
% This function shouldn't intentionally raise any warnings.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Check for required input argumnts
if nargin < 1
  warning('Expected 1 input argument');
end

% Check we have work to do
if isempty(tmr)
  return;
end

% Check object is a timer
if ~isa(tmr, 'timer')
  warning('Object is not a timer');
end

% Try to clean it up
try
  stop(tmr);
  delete(tmr);
catch ME
    disp(getReport(ME, 'extended', 'hyperlinks', 'on'));
end
  
end