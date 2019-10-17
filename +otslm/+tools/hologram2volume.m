function volume = hologram2volume(hologram, varargin)
% Generate 3-D volume representation from hologram.
%
% This function is only the inverse of volume2hologram when interpolation
% is disabled for both.
%
% Usage
%   volume = hologram2volume(hologram, ...) generates a 3-D volume for
%   2-D complex amplitude hologram.  Unwraps hologram onto Ewald sphere.
%
% Parameters
%   hologram (numeric) -- 2-D hologram to map to Ewald sphere.
%
% Optional named arguments
%  - 'interpolate' (logical) -- Interpolate between the nearest two
%    pixels in the z-direction.  (default: True)
%  - 'padding' (numeric) -- Padding in the axial direction (default 0).
%  - 'focal_length' (numeric) -- focal length in pixels (default: min(size)/2).
%  - 'zsize' (size) -- size for z depth (default: [])
%    The total z size is zsize + 2*padding.
%
% See also :func:`volume2hologram` and :class:`prop.FftEwaldForward`

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('interpolate', true);
p.addParameter('focal_length', min(size(hologram))/2);
p.addParameter('padding', 0);
p.addParameter('zsize', []);
p.parse(varargin{:});

% Hologram should already be complex (for most cases)
if isreal(hologram)
  warning('otslm:tools:hologram2volume:real_pattern', ...
      'Hologram should be complex');
end

% Calculate the depth of the lens volume
xsize = min(size(hologram));
focallength = p.Results.focal_length;

zsize_min = focallength - sqrt(focallength.^2 - (xsize/2).^2);
zsize = p.Results.zsize;
if isempty(zsize)
  zsize = ceil(zsize_min);
elseif zsize < zsize_min
  warning('otslm:tools:hologram2volume:zsize_small', ...
    'Part of lens is not captured by volume size');
end

% Calculate padding due to zsize
zoffset = max((zsize - zsize_min)/2, 0);
if ~isreal(zoffset)
  zoffset = 0;
end

% Allocate memory for the volume
volume = zeros([size(hologram), zsize]);

% Compute the real an imaginary parts separately (optimisation, R2018a)
volumeI = volume;

% Assign hologram values to the volume
for ii = 1:size(hologram, 2)
  for jj = 1:size(hologram, 1)

    value = hologram(jj, ii);

    % Calculate x and y locations in 3-D space
    xloc = ii - 0.5 - size(hologram, 2)/2;
    yloc = jj - 0.5 - size(hologram, 1)/2;

    % Calculate z location
    zloc = sqrt(focallength.^2 - xloc.^2 - yloc.^2);

    if isreal(zloc)
      zidx = focallength - zloc + zoffset;

      if p.Results.interpolate

        % Interpolate between neighbouring pixels
        zidx_low = floor(zidx + 0.5);
        zidx_high = ceil(zidx + 0.5);
        weight = mod(zidx, 1);

        if zidx_low >= 1 && zidx_high <= size(volume, 3)
          volume(jj, ii, zidx_low) = weight*real(value);
          volume(jj, ii, zidx_high) = (1.0-weight)*real(value);
          volumeI(jj, ii, zidx_low) = weight*imag(value);
          volumeI(jj, ii, zidx_high) = (1.0-weight)*imag(value);
        elseif zidx_low >= 1 && zidx_low <= size(volume, 3)
          volume(jj, ii, zidx_low) = real(value);
          volumeI(jj, ii, zidx_low) = imag(value);
        elseif zidx_high >= 1 && zidx_high <= size(volume, 3)
          volume(jj, ii, zidx_high) = real(value);
          volumeI(jj, ii, zidx_high) = imag(value);
        end
      else
        zidx = round(zidx + 0.5);

        % If point within volume, assign it
        if zidx >= 1 && zidx <= size(volume, 3)
          volume(jj, ii, zidx) = real(value);
          volumeI(jj, ii, zidx) = imag(value);
        end
      end
    end

  end
end

% Combine the real and imaginary components
volume = complex(volume, volumeI);

% Pad the array
volume = padarray(volume, [0, 0, p.Results.padding], 0, 'both');

