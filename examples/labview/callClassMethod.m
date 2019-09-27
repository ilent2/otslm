function varargout = callClassMethod(varname, classname, methodname, varargin)
% LabView helper function for calling a class method
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

assert(~isempty(varname), 'varname must be supplied');

tmpvarname = 'ourargs';

if isempty(methodname) && ~isempty(classname)
  
  % Create a new instance of the class
  assignin('base', tmpvarname, varargin);
  evalin('base', [varname, ' = ', classname, '(', tmpvarname, '{:});']);

elseif isempty(classname) && ~isempty(methodname)
  
  % Call a class method
  assignin('base', tmpvarname, varargin);
  [varargout{1:nargout}] = evalin('base', [varname, '.', methodname, '(', tmpvarname, '{:});']);
  
else
  error('Only classname or methodname must be supplied');
  
end