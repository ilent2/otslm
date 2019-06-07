classdef WebcamCamera < otslm.utils.Viewable
%WEBCAMCAMERA connect to a webcam camera connected to the computer
%
% This call can be used to create a otslm.utils.Viewable instance for
% a videoinput source.  This requires the Image Acquisition Toolbox.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.
  
  properties (SetAccess=protected)
    size        % Resolution of the device
  end
  
  properties (SetAccess=public)
    device      % The physical device (gige object)
  end
  
  properties (Dependent=true)
    Exposure     % Camera exposure
    Gain         % Camera Gain
    FrameRate    % Frame rate for device
  end
  
  methods
    function obj = WebcamCamera(varargin)
      % Connect to the camera
      %
      % cam = WebcamCamera(device_id) conntect to the specified
      % webcam camera.  For the device id, imaqhwinfo.
      %
      % If the device you are interested in is not listed, try
      % resetting/clearing all devices with imaqreset.
      
      % Parse inputs
      p = inputParser;
      p.addRequired('device_id');
      p.parse(varargin{:});
      
      % Call base class constructor
      obj = obj@otslm.utils.Viewable();
      
      % Connect to the device
%       obj.device = webcam(p.Results.device_id);

      obj.device = videoinput('winvideo', p.Results.device_id);
%       obj.device.SelectedSourceName = 'input1';
%       obj = videoinput('winvideo', p.Results.device_id, 'MJPG_1920x1080');
      
%       % Acquire the device size
%       width = obj.device.Width;
%       height = obj.device.Height;
%       obj.size = [height, width];

%       obj.device.FramesPerTrigger = 1;
      triggerconfig(obj.device, 'manual');
      start(obj.device);

      % Calculate width from image
      im = obj.view();
      width = size(im, 2);
      height = size(im, 1);
      obj.size = [height, width];
    end
    
    function delete(obj)
      % Ensure the camera is closed on exit
      delete(obj.device);
    end
    
    function set.Exposure(cam, val)
      stop(cam.device);
      src = getselectedsource(cam.device);
      src.ExposureMode = 'manual';
      src.Exposure = val;
      start(cam.device);
    end
    
    function val = get.Exposure(cam)
      stop(cam.device);
      src = getselectedsource(cam.device);
      src.ExposureMode = 'manual';
      val = src.Exposure;
      start(cam.device);
    end
    
    function set.Gain(cam, val)
      stop(cam.device);
      src = getselectedsource(cam.device);
      src.Gain = val;
      start(cam.device);
    end
    
    function val = get.Gain(cam)
      stop(cam.device);
      src = getselectedsource(cam.device);
      val = src.Gain;
      start(cam.device);
    end
    
    function set.FrameRate(cam, val)
      stop(cam.device);
      src = getselectedsource(cam.device);
      src.FrameRate = val;
      start(cam.device);
    end
    
    function val = get.FrameRate(cam)
      stop(cam.device);
      src = getselectedsource(cam.device);
      val = src.FrameRate;
      start(cam.device);
    end
    
    function varargout = view(obj)
      % Acquire a single frame from the device
%       im = snapshot(obj.device);
        im = getsnapshot(obj.device);
%       im = getdata(obj.device, 1, 'uint16');

        % Display result if no output requested
        if nargout == 0
          imagesc(im);
        else
          varargout{1} = im;
        end
    end
  end
end

