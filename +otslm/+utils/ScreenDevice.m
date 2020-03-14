classdef ScreenDevice < otslm.utils.Showable
% Represents a device controlled by a window on the screen
% Inherits from :class:`Showable`.
%
% Useful for displaying images on SLMs and DMDs connected as a screen
% on the computer running Matlab.
%
% The actual target device size may be smaller than the size
% reported by the device.
%
% See also ScreenDevice, show, otslm.utils.Showable.

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties (SetAccess=private)
    figure_handle;          % Matlab figure handle
    image_handle;           % Matlab image handle
    device_number;          % Screen number
    value_order;            % Order of the pixel value columns
    doublebuffer;           % Double buffer the Matlab image
  end

  properties (Dependent)
    device_size             % Reported size of screen [rows, columns]
  end

  properties (SetAccess=protected)
    valueRange              % Range of values for screen
    lookupTable             % Lookup table for colour mapping
    patternType             % Pattern type
    offset                  % Offset for target screen [rows, cols]
  end
  
  properties
    default_fullscreen  logical % Should showRaw use fullscreen by default
    size                    % Target screen size [rows, columns]
  end
  
  methods (Static)
    
    function positions = getMonitorPositions()
      % Get the monitor positions in pixels using java
      %
      % This is a workaroud for the get(0, 'MonitorPositions')
      % function not returning monitors connected after starting Matlab.
      %
      % This also gets the monitor size in pixels instead of virtual pix.
      %
      % Based on https://au.mathworks.com/matlabcentral/answers/312738-how-to-get-real-screen-size
      
      ge = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment();
      gds = ge.getScreenDevices();
      
      % bouds returns height in DPI modified units, displayMode
      % returns height in actual units, so we need a conversion factor
      % Unfortunatly we can't just use the DPI value since it doesn't
      % update when we change the display DPI (it only updates when
      % we logout and back in on Windows).
      defaultScreenDisplay = ge.getDefaultScreenDevice().getDisplayMode();
      defaultScreenBounds = ge.getDefaultScreenDevice().getDefaultConfiguration().getBounds();
      dpiConversion = defaultScreenDisplay.getHeight ./ defaultScreenBounds.height;
      
      positions = zeros(0, 4);
      for ii = 1:length(gds)
        bounds = gds(ii).getDefaultConfiguration().getBounds();
        displayMode = gds(ii).getDisplayMode();
        
        thisDpiConversion = displayMode.getHeight ./ bounds.height;
        
        positions(ii, :) = [(bounds.x)*thisDpiConversion + 1, ...
            dpiConversion*defaultScreenBounds.height - thisDpiConversion*(bounds.y + bounds.height) + 1, ...
            displayMode.getWidth, displayMode.getHeight];
      end
    end
    
    function num = getScreenCount()
      % Get the number of screens currently detected
      
      ge = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment();
      gds = ge.getScreenDevices();
      
      num = length(gds);
      
    end
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
      %   - 'size'   [r,c]  -- Size of the device within the window
      %     Default: `[]`, (i.e. `slm.device_size`)
      %   - 'offset' [r,c]  -- Offset within the window.  Negative
      %     values are offset from the top of the screen.
      %     Default: `[0, 0]`
      %   - 'lookup_table'  table  -- Lookup table to use for device
      %     Default lookup table is value_range{1} repeated for each channel.
      %   - 'value_range'   table  -- Cell array of value ranges
      %     Default is 256x3 for a RGB screen
      %   - 'pattern_type'  type   -- Type of pattern the device displays.
      %     Default is amplitude.
      %   - 'fullscreen'    bool   -- Default value for showRaw/fullscreen
      %   - 'prescaledPatterns'  bool  If the pattern is already pre-scaled.

      p = inputParser;
      p.addRequired('device_number');
      p.addParameter('size', []);
      p.addParameter('offset', [0, 0]);
      p.addParameter('lookup_table', []);
      p.addParameter('value_range', { 0:255, 0:255, 0:255 });
      p.addParameter('pattern_type', 'amplitude');
      p.addParameter('doublebuffer', 'off');
      p.addParameter('linear_order', []);
      p.addParameter('fullscreen', false);
      p.addParameter('prescaledPatterns', false);
      p.parse(varargin{:});
      
      % Call base class constructor
      obj = obj@otslm.utils.Showable('prescaledPatterns', p.Results.prescaledPatterns);

      % Set-up dependent properties for java window
      obj.figure_handle = [];
      obj.device_number = p.Results.device_number;
      obj.doublebuffer = p.Results.doublebuffer;
      obj.linear_order = p.Results.linear_order;

      % Store other properties
      obj.valueRange = p.Results.value_range;
      obj.patternType = p.Results.pattern_type;
      obj.offset = p.Results.offset;
      obj.default_fullscreen = p.Results.fullscreen;

      % Store or generate the lookup table
      if isempty(p.Results.lookup_table)
        table = uint8(obj.valueRange{1}.');
        %table = table ./ max(abs(table(:)));
        %table = table + min(table(:));
        obj.lookupTable = repmat(table, ...
            [1, length(obj.valueRange)]);
      else
        obj.lookupTable = p.Results.lookup_table;
      end

      % Store the device target size (or use reported size)
      if isempty(p.Results.size)
        obj.size = obj.device_size;
      else
        obj.size = p.Results.size;
      end
      
      % Conert from negative to positive offset
      if obj.offset(1) < 0
        obj.offset(1) = obj.device_size(1) + obj.offset(1);
      end
      if obj.offset(2) < 0
        obj.offset(2) = obj.device_size(2) + obj.offset(2);
      end

      % Check target size is ok
      assert(all(obj.offset >= 0), 'Offset must be >= 0');
      
      if obj.size(1) + obj.offset(1) > obj.device_size(1) ...
          || obj.size(2) + obj.offset(2) > obj.device_size(2)
        warning('otslm:utils:ScreenDevice:screen_outside', ...
          'Screen may be positioned outside device');
      end

    end

    function delete(obj)
      % Delete the object, closes the screen and frees resources
      obj.close();
    end
    
    function set.device_number(slm, val)
      % Add checks for valid device_number
      
      assert(isnumeric(val) && isscalar(val), ...
        'Device number must be numeric scalar');
      assert(floor(val) == val, 'Device number must be integer');
      
      assert(val > 0 && val <= slm.getScreenCount(), ...
        'Device number must be between 1 and number of screens');
      
      slm.device_number = val;
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
      if ~isempty(obj.figure_handle) && ishandle(obj.figure_handle)
        close(obj.figure_handle);
      end
    end

    function showRaw(obj, varargin)
      % Show the window and (optionally) display an image
      %
      % showRaw() display a blank screen.
      %
      % showRaw(img) display an image on the screen.
      % The image should have 1 or 3 channels.
      %
      % showRaw(frames) displays frames using the movie command.
      % frames should be an array of frames generated by im2frame.
      % showRaw(frame, 'framerate', rate) specifies the frame rate.
      % showRaw(frame, 'play', times) specifies time to play (see movie).

      p = inputParser;
      p.addOptional('pattern', [], @(x)isnumeric(x)||isstruct(x));
      p.addParameter('framerate', 20);
      p.addParameter('play', 1);
      p.addParameter('fullscreen', obj.default_fullscreen);
      p.parse(varargin{:});
      
      img = p.Results.pattern;
      if isempty(img)
        img = zeros([obj.size, 3], 'uint8');
      end

      if ~isa(img, 'struct')

        % Check size of image is ok
        assert(all([size(img, 1), size(img, 2)] == obj.size), ...
            'Image size must be same as target region siez');
        assert(size(img, 3) == 1 || size(img, 3) == 3, ...
            'Number of channels in image must be 1 or 3');

        % Replace NAN with first value from colourspace
        if any(isnan(img))
          
          % Get the first linear index value
          valueTable = slm.linearValueRange('structured', true);
          nanvalue = valueTable(:, 1);
          
          img(isnan(img)) = repmat(nanvalue.', ...
              [sum(sum(isnan(img(:, :, 1)))), 1]);
        end

        % Convert image from double to uint8 (for speed)
        if isa(img, 'double')
          img = uint8(img);
        end
      end

      % Open the window if required
      if isempty(obj.figure_handle) || ~ishandle(obj.figure_handle)
        
        % Get the position of the desired monitor
        monitor_positions = obj.getMonitorPositions();
        oposition = monitor_positions(obj.device_number, :);
        
        if p.Results.fullscreen

          obj.figure_handle = figure( ...
              'Visible', 'on', ...    % Needed for live scripts
              'WindowState', 'fullscreen', ...
              'menubar','none', ...
              'NumberTitle','off', ...
              'units','pixels', ...
              'outerposition',oposition, ...
              'doublebuffer', obj.doublebuffer, ...
              'IntegerHandle', 'off');
        else
          obj.figure_handle = figure( ...
              'Visible', 'on', ...    % Needed for live scripts
              'menubar','none', ...
              'NumberTitle','off', ...
              'units','pixels', ...
              'Position', [oposition(1:2) + obj.offset([2, 1]), obj.size(2), obj.size(1)], ...
              'doublebuffer', obj.doublebuffer, ...
              'IntegerHandle', 'off');
        end
        
        % Make the window display on-top
        otslm.utils.thirdparty.WinOnTop(obj.figure_handle);
      end

      if isa(img, 'struct') || ...
          isempty(obj.image_handle) || ~ishandle(obj.image_handle)

        % Create the axes (and image handle)
        if isa(img, 'struct')
          obj.image_handle = [];
          axes_handle = axes(obj.figure_handle);
        else
          % Explicitly create the axes, not sure why this is necessary,
          % but implicit axes creation was causing problems in the lab
          axes_handle = axes(obj.figure_handle);
          obj.image_handle = image(axes_handle, img);
        end

        % Set the axes properties
        set(axes_handle, ...
            'units', 'pixels', ...
            'position', [1, 1, obj.size(2), obj.size(1)], ...
            'YTickLabel', [], ...
            'XTickLabel', [], ...
            'YTick', [], ...
            'XTick', [], ...
            'xlimmode','manual', ...
            'ylimmode','manual', ...
            'zlimmode','manual', ...
            'climmode','manual', ...
            'alimmode','manual', ...
            'box', 'off');
          
          % Hide the axis rulers
          axes_handle.XAxis.Visible = 'off';
          axes_handle.YAxis.Visible = 'off';
          
        % The full screen window is placed in the window coordinates
        % instead of the global coordinates, so adjust the size accordingly
        if p.Results.fullscreen
          set(axes_handle, 'position', [0, 0, obj.size(2), obj.size(1)]);
        end
          
        drawnow;

        % Display the movie (if struct)
        if isa(img, 'struct')
          movie(axes_handle, img, p.Results.play, p.Results.framerate);
        end

      else
        set(obj.image_handle, 'CData', img);
          
        % If single chanel range, set grayscale colormap
        if size(img, 3) == 1
          colormap(imgca(obj.figure_handle), gray);
        end

        drawnow nocallbacks;
      end
    end
    
    function set.size(slm, value)
      % Change the size of the window
      
      assert(numel(value) == 2, 'value must be 2 element vector');
      
      % TODO: Should this change?
      
      slm.size = value;
    end
  end
end

