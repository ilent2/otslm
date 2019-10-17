function [output, filtered] = spatial_filter(input, filter, varargin)
% Applies a spatial filter to the image spectrum
%
% Usage
%   [output, filtered] = spatial_filter(input, filter, ...)
%   applies filter to the
%   Fourier transform of input and calculates the inverse Fourier
%   transform to give output.  Optional output filtered is the filtered
%   pattern.
%
% Parameters
%   - input (numeric) -- image to apply filter to
%   - filter -- a mask pattern to apply to the far-field of the input.
%
% Optional named parameters
%   - 'padding' (numeric)      -- Add padding to the outside of the image
%     (default: 100).
%   - 'keep_padding' (logical) -- Keep or discard padding after filter
%     (default: false).
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('padding', 100);
p.addParameter('keep_padding', false);
p.parse(varargin{:});

pad = p.Results.padding;

% Calculate pattern in conjugate plane
filtered = otslm.tools.visualise([], 'incident', input, ...
    'method', 'fft', 'type', 'farfield', 'padding', pad);

% Apply the filter

assert(all(size(filter) <= size(filtered)), ...
  'Size of filter must be smaller than input+2*padding');

fsz = size(filter);
padr = floor((size(filtered) - fsz)/2);
filtered_roi = false(size(filtered));
filtered_roi(padr(1)+(1:fsz(1)), padr(2)+(1:fsz(2))) = true;
filtered(filtered_roi) = filtered(filtered_roi) .* filter(:);
filtered(~filtered_roi) = 0.0;

% Calculate pattern in output plane (no extra padding)
output = otslm.tools.visualise([], 'incident', filtered, ...
    'method', 'fft', 'type', 'nearfield', 'padding', 0);

% Remove padding if asked

if ~p.Results.keep_padding
  output = output(pad+1:end-pad, pad+1:end-pad);
end
