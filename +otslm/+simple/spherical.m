function pattern = spherical(sz, radius, varargin)
% SPHERICAL generates a spherical lens pattern
%
% pattern = spherical(sz, radius, ...) generates a spherical lens with
% specified radius.  Default location is centre of image.  Values
% outside the spehre are replaced with +/- Inf depending on sign of
% radius, but this can be modified with the named parameters.
%
% See simple.aspheric for more information and named arguments.

pattern = otslm.simple.aspheric(sz, radius, 0, varargin{:});

