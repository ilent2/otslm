classdef DmdScreen < ScreenDevice
  %DmdScreen Controller for DMD screen device with binary display
  %
  % Copyright (C) 2018 Isaac Lenton (aka ilent2)

  properties
  end

  methods
    function obj = DmdScreen(varargin)
      %DmdScreen Connect to a DMD
      %
      % DmdScreen(device_id) constructs a new DMD screen.
      %
      % DmdScreen(..., 'target_size', size) specifies the device
      % to display the window on and the target resolution of the DMD.

      obj = obj@ScreenDevice(varargin{:});
    end
    
    function show(obj, img)
      % Display an image, first converting it to logical array.
      %
      % If the image is a double array, true values are assigned if
      % the double value is greater/equal to than 0.5.
      %
      % For uint8 arrays, values greater than 128 are true.
      %
      % For logical arrays, the array is unchanged.
      
      if nargin == 2
        
        if isa(img, 'double')
          img = img >= 0.5;
        elseif isa(img, 'uint8')
          img = img >= 128;
        elseif isa(img, 'logical')
          % Nothing to do
        else
          error('Unrecognized type');
        end
        
        show@ScreenDevice(obj, img);
      else
        show@ScreenDevice(obj);
      end
    end
  end
end

