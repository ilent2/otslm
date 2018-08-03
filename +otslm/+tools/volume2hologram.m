function hologram = volume2hologram(volume, varargin)
% VOLUME2HOLOGRAM generate hologram from 3-D volume
%
% hologram = volume2hologram(volume, ...) calculates the overlap
% of the Ewald sphere with the volume and projects it to a 2-D hologram.
%
% This function is only the inverse of hologram2volume when interpolation
% is disabled for both.
%
% Optional named arguments:
%   'interpolate'   value   Interpolate between the nearest two
%       pixels in the z-direction.  Default: true.
%
% See also: otslm.tools.hologram2volume, otslm.iter.gs3d
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('interpolate', true);
p.parse(varargin{:});

% Calculate the focal length of the lens (assuming no padding)
xsize = min(size(volume, 1), size(volume, 2));
zsize = size(volume, 3);
focallength = ((xsize/2).^2 + zsize.^2)/(2*zsize);

% Allocate memory for hologram
hologram = zeros(size(volume, 1), size(volume, 2));

% Assign volume values to hologram
for ii = 1:size(hologram, 2)
  for jj = 1:size(hologram, 1)

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
          value = weight*volume(jj, ii, zidx_low);
          value = value + (1.0-weight)*volume(jj, ii, zidx_high);
        elseif zidx_low <= size(volume, 3)
          value = volume(jj, ii, zidx_low);
        end
      else
        zidx = round(zidx + 1);

        % If point within volume, assign it
        if zidx <= size(volume, 3)
          value = volume(jj, ii, zidx);
        end
      end

      hologram(jj, ii) = value;
    end

  end
end

