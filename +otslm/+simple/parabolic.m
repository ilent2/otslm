function pattern = parabolic(sz, alphas, varargin)
% PARABOLIC generates a parabolic lens pattern
%
% pattern = parabolic(sz, alphas, ...) generates a parabolic lens, the
% equation describing this lens is
%
%   z(r) = alpha_1*r^2 + alpha_2*r^4 + alpha_3*r^6 + ...
%
% The default centre for the lens is the centre of the pattern,
% this can be modified with named parameters.
%
% See simple.aspheric for more information and named parameters.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

assert(length(alphas) >= 1, 'Must provide at least one alpha');

% alpha_1 = 1/(2*R) -> R = 1/(2*alpha_1)
radius = 1.0 / (alphas(1) * 2.0);

alpha_remaining = [];
if length(alphas) > 1
  alpha_remaining = alphas(2:end);
end

pattern = otslm.simple.aspheric(sz, radius, -1, ...
    'alpha', alpha_remaining, varargin{:});

