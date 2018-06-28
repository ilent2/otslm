classdef ScreenDevice < otslm.utils.Showable, handle
  %ScreenDevice Represents a device controlled by full screen window
  %   Base class used for SlmScreen and DmdScreen devices.
  %
  %  The actual target device size may be smaller than the size
  %  reported by the device.
  %
  % Copyright (C) 2018 Isaac Lenton (aka ilent2)

  properties (SetAccess=private)
    java_window;            % Java window obejct
    java_icon;              % Java icon object
    
    device_number;          % Screen number
    device_width;           % Screen reported width
    device_height;          % Screen reported height
    
    width;                  % Target screen width
    height;                 % Target screen height
    
    temp_file;              % Temoprary file for screen device
  end

  methods
    function obj = ScreenDevice(varargin)
      %ScreenDevice Construct a new instance of the screen device.
      
      p = inputParser;
      p.addRequired('device_number');
      p.addParameter('target_size', []);
      p.parse(varargin{:});
      
      obj.device_number = p.Results.device_number;
      obj.temp_file = [tempname(),  '.bmp'];
      obj.java_window = [];
      
      % Get the device reported size
      ge = java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment();
      gds = ge.getScreenDevices();
      obj.device_width = gds(obj.device_number).getDisplayMode().getWidth();
      obj.device_height = gds(obj.device_number).getDisplayMode().getHeight();
      
      % Store the device target size (or use reported size)
      if isempty(p.Results.target_size)
        obj.width = obj.device_width;
        obj.height = obj.device_height;
      else
        obj.width = p.Results.target_size(2);
        obj.height = p.Results.target_size(1);
      end
      
      % Check target size is ok
      assert(obj.width <= obj.device_width, ...
        ['Target width must be <= ' num2str(obj.device_width)]);
      assert(obj.height <= obj.device_height, ...
        ['Target height must be <= ' num2str(obj.device_height)]);
      
    end
    
    function delete(obj)
      % Delete the object, closes the screen and frees resources
      obj.close();
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
    
    function show(obj, img)
      % Show the window and (optionally) display an image
      %
      %  show() display a blank screen.
      %
      %  show(img) display an image on the screen.
      
      if nargin >= 2
          
        
        % Check size of image is ok
        assert(size(img, 1) == obj.height, ...
          ['Image height should be ' num2str(obj.height)]);
        assert(size(img, 2) == obj.width, ...
          ['Image width should be ' num2str(obj.width)]);
        
        if size(img, 3) == 1
          blank = zeros(obj.device_height, obj.device_width, class(img));
          blank(1:obj.height, 1:obj.width) = img;
        else
          blank = zeros(obj.device_height, obj.device_width, 3, class(img));
          blank(1:obj.height, 1:obj.width, :) = img;
        end
        
      else
        blank = zeros(obj.device_height, obj.device_width);
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

