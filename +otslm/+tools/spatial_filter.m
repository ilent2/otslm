function [output, filtered] = spatial_filter(input, filter, varargin)
% Applies a spatial filter to the image spectrum.
% This can be used to simulate imaging or focussing of light using
% an objective with different shaped apertures or for adding spherical
% aberration to the system.
%
% Usage
%   [output, filtered] = spatial_filter(input, filter, ...)
%   Applies filter to the Fourier transform of input and
%   calculates the inverse Fourier transform to give output.
%   Optional output filtered is the filtered pattern.
%
% Parameters
%   - input (numeric) -- image to apply filter to.
%   - filter (numeric) -- a mask pattern to apply to the far-field
%     of the input.  Should be the same size or smaller than the
%     output of the forward propagation method.  If it is smaller,
%     the array is padded with zeros.
%
% Optional named parameters
%   - vismethod (fcn)   -- Function to calculate far-field.  Takes one
%     argument, the complex amplitude near-field.
%     Default: @otslm.tools.prop.FftForward.simpleProp.evaluate
%
%   - invmethod (fcn)   -- Function to calculate near-field.  Takes one
%     argument: the complex amplitude far-field.
%     Default: @otslm.tools.prop.FftInverse.simpleProp.evaluate
%
%   - gpuArray (logical) -- If the result should be a gpuArray.
%     Default: ``isa(input, 'gpuarray')``.
%
% Padding can be controlled by changing the vis and inv methods.
%
% See also :scpt:`examples.liveScripts.booth1998`

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('vismethod', []);
p.addParameter('invmethod', []);
p.addParameter('gpuArray', isa(input, 'gpuArray'))
p.parse(varargin{:});

% Handle default visualisation and inverse methods
vismethod = p.Results.vismethod;
if isempty(vismethod)
  prop = otslm.tools.prop.FftForward.simpleProp(input, ...
      'gpuArray', p.Results.gpuArray);
  vismethod = @prop.propagate;
end
invmethod = p.Results.invmethod;
if isempty(invmethod)
  prop = otslm.tools.prop.FftInverse.simpleProp(input, ...
      'gpuArray', p.Results.gpuArray);
  invmethod = @prop.propagate;
end

% Calculate pattern in conjugate plane
filtered = vismethod(input);

% Apply the filter

assert(all(size(filter) <= size(filtered)), ...
  'Size of filter must be smaller than vismethod output');

fsz = size(filter);
padr = floor((size(filtered) - fsz)/2);
filtered_roi = false(size(filtered));
filtered_roi(padr(1)+(1:fsz(1)), padr(2)+(1:fsz(2))) = true;
filtered(filtered_roi) = filtered(filtered_roi) .* filter(:);
filtered(~filtered_roi) = 0.0;

% Calculate pattern in output plane (no extra padding)
output = invmethod(filtered);

