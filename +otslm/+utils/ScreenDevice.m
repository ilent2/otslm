classdef ScreenDevice < otslm.utils.Showable
% ScreenDevice Represents a device controlled by full screen window
% Base class used for SlmScreen and DmdScreen devices.
%
% The actual target device size may be smaller than the size
% reported by the device.
%
% Copyright (C) 2018 Isaac Lenton (aka ilent2)

  properties (SetAccess=private)
    java_window;            % Java window obejct
    java_icon;              % Java icon object

    device_number;          % Screen number
    temp_file;              % Temoprary file for screen device
  end

  properties (Dependent)
    device_size             % Reported size of screen [rows, columns]
  end

  properties (SetAccess=protected)
    valueRange              % Range of values for screen
    lookupTable             % Lookup table for colour mapping
    patternType             % Pattern type
    size                    % Target screen size [rows, columns]
    offset                  % Offset for target screen [rows, columns]
  end

  methods
    function obj = ScreenDevice(varargin)
      %ScreenDevice Construct a new instance of the screen device.
      %
      % screen = ScreenDeivce(device_number, ...) creates a new
      % screen device for the specified physical device.  Patterns
      % are assumed to be amplitude based, value range is RGB.
      %
      % Optional named parameters:
      %
      %   'target_size'   [r,c]   Size of the device within the window
      %   'target_offset' [r,c]   Offset within the window
      %   'lookup_table'  table   Lookup table to use for device
      %       Default lookup table is value_range{1} repeated for each channel.
      %   'value_range'   table   Cell array of value ranges
      %       Default is 256x3 for a RGB screen
      %   'pattern_type'  type    Type of pattern the device displays.
      %       Default is amplitude.

      p = inputParser;
      p.addRequired('device_number');
      p.addParameter('target_size', []);
      p.addParameter('target_offset', [0, 0]);
      p.addParameter('lookup_table', []);
      p.addParameter('value_range', { 0:255, 0:255, 0:255 });
      p.addParameter('pattern_type', 'amplitude');
      p.parse(varargin{:});

      % Set-up dependent properties for java window
      obj.device_number = p.Results.device_number;
      obj.temp_file = [tempname(),  '.bmp'];
      obj.java_window = [];

      % Store other properties
      obj.valueRange = p.Results.value_range;
      obj.patternType = p.Results.pattern_type;
      obj.offset = p.Results.target_offset;

      % Store or generate the lookup table
      if isempty(p.Results.lookup_table)
        table = obj.valueRange{1}.';
        table = table ./ max(abs(table(:)));
        table = table + min(table(:));
        obj.lookupTable = repmat(table, ...
            [1, length(obj.valueRange)]);
      else
        obj.lookupTable = p.Results.lookup_table;
      end

      % Store the device target size (or use reported size)
      if isempty(p.Results.target_size)
        obj.size = obj.device_size;
      else
        obj.size = p.Results.target_size;
      end

      % Check target size is ok
      assert(all(obj.offset >= 0), 'Offset must be >= 0');
      assert(obj.size(1) + obj.offset(1) <= obj.device_size(1), ...
        ['Target max row must be <= ' num2str(obj.device_size(1))]);
      assert(obj.size(2) + obj.offset(2) <= obj.device_size(2), ...
        ['Target max column must be <= ' num2str(obj.device_size(2))]);

    end

    function delete(obj)
      % Delete the object, closes the screen and frees resources
      obj.close();
    end

    function sz = get.device_size(obj)
      % Get the device reported size

      ge = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment();
      gds = ge.getScreenDevices();
      device_width = gds(obj.device_number).getDisplayMode().getWidth();
      device_height = gds(obj.device_number).getDisplayMode().getHeight();

      sz = [device_height, device_width];
    end

    function close(obj)
      % Close the window used to control the device

      % Try closing the window
      if ~isempty(obj.java_window)
        try
          obj.java_window.dispose();
          obj.java_window = [];
        catch
            warning('Unable to close window');
        end
      end

      % Try removing the temp file
      if exist(obj.temp_file, 'file')
        try
          delete(obj.temp_file);
        catch
          warning('Unable to delete temp file');
        end
      end
    end

    function showRaw(obj, img)
      % Show the window and (optionally) display an image
      %
      % showRaw() display a blank screen.
      %
      % showRaw(img) display an image on the screen.
      % The image should have 1 or 3 channels.

      if nargin >= 2

        % Check size of image is ok
        assert(all([size(img, 1), size(img, 2)] == obj.size), ...
            'Image size must be same as target region siez');
        assert(size(img, 3) == 1 || size(img, 3) == 3, ...
            'Number of channels in image must be 1 or 3');

        % Generate blank image
        if size(img, 3) == 3
          blank = zeros([obj.device_size, 3], class(img));
          blank(obj.offset(1)+(1:obj.size(1)), ...
              obj.offset(2)+(1:obj.size(2)), :) = img;
        elseif size(img, 3) == 1
          blank = zeros(obj.device_size, class(img));
          blank(obj.offset(1)+(1:obj.size(1)), ...
              obj.offset(2)+(1:obj.size(2))) = img;
        end

      else
        blank = zeros(obj.device_size);
      end

      imwrite(blank, obj.temp_file);
      buff_image = javax.imageio.ImageIO.read(...
          java.io.File(obj.temp_file));

      ge = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment();
      gds = ge.getScreenDevices();

      if isempty(obj.java_window)
          obj.java_window = javax.swing.JFrame(...
              gds(obj.device_number).getDefaultConfiguration());
          obj.java_window.setUndecorated(true);
          obj.java_icon = javax.swing.ImageIcon(buff_image);
          label = javax.swing.JLabel(obj.java_icon);
          obj.java_window.getContentPane.add(label);
          obj.java_window.setExtendedState(obj.java_window.MAXIMIZED_BOTH);
      else
          obj.java_icon.setImage(buff_image);
      end

      obj.java_window.pack
      obj.java_window.repaint
      obj.java_window.show
    end
  end
end

