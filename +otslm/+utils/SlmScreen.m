classdef SlmScreen < ScreenDevice
  %SlmScreen Controller for SLM screen objects with 8 or 16 bit displays
  %
  % Copyright (C) 2018 Isaac Lenton (aka ilent2)

  properties
    lookup_table
  end
  
  methods (Static)
      
    function output = reverse(input)
      % Reverse the bit order of input.  Input must be uint8.
      
      output = uint8(0);
      for ii = 1:8
        output = bitor(output, bitand(input, 2^(ii-1))*2^(7-2*(ii-1)));
      end
    end
      
    function lookup_table = lookup_table_file16(filename, channels, order)
      % Loads a 16-bit lookup table from a file
      %
      % lookup_table_from_file(filename) loads the lookup table.
      % The lookup table should be a file with a header line.
      % If the file has multiple columns, only the last colum is used.
      % The file should only contain the [0, 2*pi) range for the SLM.
      % The values in the file should be uint16, the first 8 bits
      % are the red channel, the second 8 bits are the green channel.
      %
      % lookup_table_from_file(filename, channels) loads a lookup
      % table as above but specifies which channel the bits correspond to.
      % Use 'rg' for first 8 bits red, second 8 bits green.
      % Other combinations of 'r', 'g', 'b' are accepted.
      %
      % Returns a Nx3 vector with values for each channel.
      
      if nargin == 2
          order = 'normal';
      end
      
      data_struct = importdata(filename, '\t');
      data = data_struct.data;
      data = uint16(data(:, end));
      
      first = uint8(bitand(data, 255));
      second = uint8(bitand(data, 255*2^8)/2^8);
      blnk = zeros(size(first), 'uint8');
      
      if strcmpi(order, 'reverse')
          first = SlmScreen.reverse(first);
          second = SlmScreen.reverse(second);
      end
      
      if nargin == 1
        channels = 'rg';
      end
      
      switch channels
        case 'rg'
          lookup_table = [first, second, blnk];
        case 'rb'
          lookup_table = [first, blnk, second];
        case 'gr'
          lookup_table = [second, first, blnk];
        case 'gb'
          lookup_table = [blnk, first, second];
        case 'br'
          lookup_table = [second, blnk, first];
        case 'bg'
          lookup_table = [blnk, second, first];
        otherwise
          error('Unknown channel option given');
      end
      
    end
    
    function lookup_table = lookup_table_file8(filename, channels)
      % Loads a 8-bit lookup table from a file
      %
      % lookup_table_from_file(filename) loads the lookup table.
      % Produces a 3xN length column vector with elements from the file.
      % If there are multiple columns, only the last column is used.
      % Columns of the file are repeated.
      %
      % lookup_table_from_file(filename, channels) loads a lookup
      % table with multiple columns in the file.  The number of
      % columns must be equal to the number of characters in channels.
      % Produces a Nx3 lookup_table.
      % Use 'rg' for first column red, second column green.
      % Other combinations of 'r', 'g', 'b' are accepted.
      
      data_struct = importdata(filename, '\t');
      data = data_struct.data;
      data = uint8(data);

      if nargin == 1
        data = data(:, end);
        lookup_table = [ data, data, data ];
      else
        
        if length(channels) > size(data, 2)
          error('Number of channels greater than number of columns');
        end
        
        lookup_table = zeros(size(data, 1), length(channels), 'uint8');
        for ii = 1:length(channels)
          switch channels(ii)
            case 'r'
              chn = 1;
            case 'g'
              chn = 2;
            case 'b'
              chn = 3;
            otherwise
              error('Unrocognized character in string');
          end
          lookup_table(:, chn) = data(:, ii);
        end
      end
    end
  end

  methods
    function slm = SlmScreen(device_id, lookup_table, target_size)
      %SlmScreen Connect to a new SLM screen object
      %
      % SlmScreen(device_id, lookup_table) specifies the screen to
      % display the image on and the lookup_table to use for
      % converting images to SLM patterns.
      %
      % SlmScreen(..., target_size) optionally specifies the size
      % of the SLM screen to target.
      
      if nargin == 2
        target_size = [];
      end
      
      slm = slm@ScreenDevice(device_id, 'target_size', target_size);
        
      slm.lookup_table = lookup_table;
    end
    
    function show(slm, img)
      % Display an image on the slm.
      %
      % For doubles, the image is assumed to be in a range [0, 1)
      % corresponding to a [0, 2*pi) range.
      %
      % For uint8 or uint16, the image is assumed to be in a range
      % of [0, 256) and [0, 65536) respectively corresponding to
      % a [0, 2*pi) range.

      % Do the interpolation
      if isa(img, 'double')
          
        if max(img(:)) > 2
            warning('Capping max value to 1');
            img(img > 1) = 1.0;
        end
        
        if min(img(:)) < 0
            warning('Capping min value to 0');
            img(img < 0) = 0.0;
        end
          
        idx = interp1(linspace(0, 1, size(slm.lookup_table, 1)), ...
            1:size(slm.lookup_table, 1), img, 'nearest');
      elseif isa(img, 'unit8')
        idx = interp1(linspace(0, 2^8-1, size(slm.lookup_table, 1)), ...
            1:size(slm.lookup_table, 1), img, 'nearest');
      elseif isa(img, 'uint16')
        idx = interp1(linspace(0, 2^16-1, size(slm.lookup_table, 1)), ...
            1:size(slm.lookup_table, 1), img, 'nearest');
      else
        error('Unknown image type');
      end
      
      % Convert each channel separately
      imgR = reshape(slm.lookup_table(idx(:), 1), size(idx));
      imgG = reshape(slm.lookup_table(idx(:), 2), size(idx));
      imgB = reshape(slm.lookup_table(idx(:), 3), size(idx));
      
      % Form the images into a 3-channel image
      img = uint8(imgR);
      img(:, :, 2) = imgG;
      img(:, :, 3) = imgB;
      
      % Display the image
      show@ScreenDevice(slm, img);
    end
  end
end

