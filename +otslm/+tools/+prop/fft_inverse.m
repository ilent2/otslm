function output = fft_inverse(pattern, varargin)
%FFT_INVERSE Propogate using inverse 2-D fast fourier transform
%
% output = fft_inverse(U, axial_offset)
%     U               complex field to propogate
%
% Optional named parameters
%     axial_offset    num    offset along the axial direction
%     padding   num | [row, col]  padding to apply to pattern
%
% See also fft_forward, fft3_inverse and otslm.tools.visualise.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser();
p.parse(varargin{:});

z = p.Results.z;
padding = p.Results.padding;
if numel(padding) == 1
  padding = [padding, padding];
end

% Apply padding to the image
U = padarray(U, padding, 0);

% Set rscale from inputs, this is determined by the
% focal length/numerical aparture of the lens (for z-shift)
rscale = 1.0./p.Results.NA;

% Calculate pattern at DOE
output = ifft2(fftshift(U));

lens = otslm.simple.spherical(size(output), ...
    rscale*sqrt(sum((size(output)/2).^2)), ...
    'background', 'checkerboard');

% Remove the z-shift using a negative lens in far-field
output = output .* exp(1i*z*lens);

% Remove padding if requested
if p.Results.trim_padding

  % Hmm, we could also resample at the original resolution

  szOutput = size(output);
  opadding = floor(szOutput/4);

  output = output(opadding(1)+1:end-opadding(1), ...
      opadding(2)+1:end-opadding(2));
end