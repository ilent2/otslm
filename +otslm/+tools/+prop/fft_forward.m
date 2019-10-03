function output = fft_forward(pattern, varargin)
%FFT_FORWARD Propogate using forward 2-D fast fourier transform
%
% output = fft_forward(U, axial_offset)
%     U               complex field to propogate
%
% Optional named parameters
%     axial_offset    num    offset along the axial direction
%     padding   num | [row, col]  padding to apply to pattern
%
% See also fft_inverse, fft3_forward and otslm.tools.visualise.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% TODO: These should be classes, then we can pre-allocate our
% resources (such as the padding, lens and anything else).
%
% We can also make our forward and inverse methods a pair.
% It this second point a good idea?

p = inputParser;
p.addParameter('axial_offset', 0.0);
p.addParameter('padding', ceil(size(pattern)/2));
p.addParameter('NA', 0.1);
p.addParameter('trim_padding', false);
p.parse(varargin{:});

padding = p.Results.padding;
if numel(padding) == 1
  padding = [padding, padding];
end

% Apply padding to the image
pattern = padarray(pattern, padding, 0);

% This is expensive, only do it if we have to
if p.Results.axial_offset ~= 0
  % Set rscale from inputs, this is determined by the
  % focal length/numerical aparture of the lens (for z-shift)
  rscale = 1.0./p.Results.NA;

  lens = otslm.simple.spherical(size(pattern), ...
      rscale*sqrt(sum((size(pattern)/2).^2)), ...
      'background', 'checkerboard');

  % Apply z-shift using a lens in the far-field
  pattern = pattern .* exp(-1i*p.Results.axial_offset*lens);
end

% Transform to the focal plane (missing scaling factor)
output = fftshift(fft2(pattern))./numel(pattern);

% Remove padding if requested
if p.Results.trim_padding

  % Hmm, we could also resample at the original resolution

  szOutput = size(output);
  opadding = floor(szOutput/4);

  output = output(opadding(1)+1:end-opadding(1), ...
      opadding(2)+1:end-opadding(2));
end

