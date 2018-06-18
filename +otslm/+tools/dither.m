function pattern = dither(pattern, level, varargin)
% DITHER creates a binary patter from gray pattern
%
% pattern = dither(pattern, level, ...) applies the default dithering,
% binary threshold, to the pattern.
%
% Most methods assume the pattern is in the range 0 to 1.
%
% Optional named parameters:
%     'method'    method      Method to use for dithering
%         Supported methods:
%             'threshold'     Apply threshold filter to image (default)
%             'mdither'       Use matlab dither function
%             'floyd'         Floyd-Steinberg algorithm
%             'random'        Does random dithering

p = inputParser;
p.addParameter('method', 'threshold');
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

