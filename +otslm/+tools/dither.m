function pattern = dither(pattern, level, varargin)
% Creates a binary pattern from gray-scale image.
% Supports several different dithering methods.
%
% Usage
%   pattern = dither(pattern, level, ...) applies the default dithering,
%   binary threshold, to the pattern.
%
% Parameters
%   - pattern (numeric) -- the gray-scale pattern.  Most methods
%     assume the pattern has values in the range 0 to 1.
%   - level (numeric) -- threshold level
%
% Optional named parameters
%   - 'method' (enum) -- Method to use for dithering. Supported methods:
%    - 'threshold' --  Apply threshold filter to image (default)
%    - 'mdither'   --  Use matlab dither function
%    - 'floyd'     --  Floyd-Steinberg algorithm
%    - 'random'    --  Does random dithering
%   - 'value'    [min, max]   Value range for output image
%     (default: [] for logical images).  See :func:`castValue`.

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('method', 'threshold');
p.addParameter('value', []);
p.parse(varargin{:});

switch p.Results.method
  case 'threshold'
    % Apply binary threshold to the image
    pattern = pattern > level;

  case 'mdither'
    % Use matlab dither method
    pattern = dither(pattern);
    
  case 'random'
    % Add noise to the pattern and threshold
    scale = 1.0;
    pattern = pattern + scale*(rand(size(pattern))-0.5);
    pattern = pattern > level;

  case 'floyd'
    % Floyd Steinberg dithering

    for ii = 1:size(pattern, 2)
      for jj = 1:size(pattern, 1)

        % Calculate the new value and error
        old = pattern(jj, ii);
        bin = 1.0*(old > level);
        err = old - bin;

        % Store the new value
        pattern(jj, ii) = bin;

        % Distribute the error
        if jj < size(pattern, 1)
          pattern(jj+1, ii) = pattern(jj+1, ii) + 7/16 * err;
        end
        if ii < size(pattern, 2)
          if jj > 1
            pattern(jj-1, ii+1) = pattern(jj-1, ii+1) + 3/16 * err;
          end
          pattern(jj, ii+1) = pattern(jj, ii+1) + 5/16 * err;
          if jj < size(pattern, 1)
            pattern(jj+1, ii+1) = pattern(jj+1, ii+1) + 1/16 * err;
          end
        end
      end
    end

    pattern = pattern == 1.0;

  case 'lee'
    % TODO: Look at Lee
    % Is this a dither method, or a tools.finalize algorithm?
    error('Not yet implemented');

  case 'superpixel'
    % TODO: Look at Superpixel dithering
    % Is this a dither method, or a tools.finalize algorithm?
    error('Not yet implemented');

  otherwise
    error('Unknown method argument for dither');

end

% Scale the pattern (convert from logical to double if required)
pattern = otslm.tools.castValue(pattern, p.Results.value);
