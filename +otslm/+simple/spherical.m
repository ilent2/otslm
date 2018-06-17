function pattern = spherical(sz, radius, varargin)
% SPHERICAL generates a spherical lens pattern
%
% pattern = spherical(sz, radius, ...) generates a spherical pattern
% with values from 0 (at the edge) and 1*sign(radius) (at the centre).
%
% pattern = spherical(sz, radius, ...) generates a spherical lens with
% specified radius.  Default location is centre of image.  Values
% outside the spehre are replaced with +/- Inf depending on sign of
% radius, but this can be modified with the named parameters.
%
% See simple.aspheric for more information and named arguments.

p = inputParser;
p.KeepUnmatched = true;
p.addParameter('imag_value', 0.0);
p.parse(varargin{:});

pattern = otslm.simple.aspheric(sz, radius, 0, varargin{:}, ...
    'imag_value', NaN);

% Scale the result
pattern = pattern ./ max(abs(pattern(:))) - sign(radius);

% Ensure result is real
imag_parts = isnan(pattern);
pattern(imag_parts) = p.Results.imag_value;

