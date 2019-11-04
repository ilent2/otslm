function pattern = replaceImagBackgroud(pattern, background, useGpuArray)
% Replace imaginary values in pattern with the background pattern
%
% Usage
%   pattern = replaceImagBackgroud(pattern, backgroudn, useGpuArray)
%
% Parameters
%   - pattern -- pattern to replace values in
%   - background (numeric|enum) -- Specifies a background pattern to use
%     for values outside the lens.  Can also be a scalar, in which case
%     all values are replaced by this value; or a string with
%     'random' or 'checkerboard' for these patterns.
%   - useGpuArray (logical) -- If the pattern should be a gpuArray.

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

imag_parts = imag(pattern) ~= 0;

if isa(background, 'char')
  switch background
    case 'random'
      background = otslm.simple.random(size(pattern), ...
          'gpuArray', useGpuArray);
    case 'checkerboard'
      background = otslm.simple.checkerboard(size(pattern), ...
          'gpuArray', useGpuArray);
    otherwise
      error('Unknown background string');
  end
  pattern(imag_parts) = background(imag_parts);
else
  if numel(background) == 1
    pattern(imag_parts) = background;
  elseif size(background) == size(imag_parts)
    pattern(imag_parts) = background(imag_parts);
  else
    error('Number of background elements must be 1 or same size as pattern');
  end
end

