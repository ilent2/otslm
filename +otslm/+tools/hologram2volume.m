function volume = hologram2volume(hologram, varargin)
% HOLOGRAM2VOLUME generate 3-D volume representation from hologram
%
% volume = hologram2volume(hologram, ...) generates a 3-D volume for
% 2-D complex amplitude hologram.  Unwraps hologram onto Ewald sphere.
%
% This function is only the inverse of volume2hologram when interpolation
% is disabled for both.
%
% Optional named arguments:
%   'interpolate'   value   Interpolate between the nearest two
%       pixels in the z-direction.  Default: true.
%   'padding'       value   Padding in the axial direction (default 0).
%   'focal_length'  value   focal length in pixels (default: min(size)/2).
%
% See also: otslm.tools.volume2hologram, otslm.iter.gs3d
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('interpolate', true);
p.addParameter('focal_length', min(size(hologram))/2);
p.addParameter('padding', 0);
p.addParameter('zlimit', []);
p.parse(varargin{:});

% Calculate the depth of the lens volume
xsize = min(size(hologram));
focallength = p.Results.focal_length;

zsize = p.Results.zlimit;
if isempty(zsize)
  zsize = focallength - sqrt(focallength.^2 - (xsize/2).^2);
end

% Allocate memory for the volume
volume = zeros([size(hologram), round(zsize)]);

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
      zidx = focallength - zloc;

      if p.Results.interpolate

        % Interpolate between neighbouring pixels
        zidx_low = floor(zidx + 1);
        zidx_high = ceil(zidx + 1);
        weight = mod(zidx, 1);

        if zidx_high <= size(volume, 3)
          volume(jj, ii, zidx_low) = weight*real(value);
          volume(jj, ii, zidx_high) = (1.0-weight)*real(value);
          volumeI(jj, ii, zidx_low) = weight*imag(value);
          volumeI(jj, ii, zidx_high) = (1.0-weight)*imag(value);
        elseif zidx_low <= size(volume, 3)
          volume(jj, ii, zidx_low) = real(value);
          volumeI(jj, ii, zidx_low) = imag(value);
        end
      else
        zidx = round(zidx + 1);

        % If point within volume, assign it
        if zidx <= size(volume, 3)
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

