classdef WebcamCamera < otslm.utils.Viewable
%WEBCAMCAMERA connect to a webcam camera connected to the computer
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
  
  methods
    function obj = WebcamCamera(varargin)
      % Connect to the camera
      
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
    
    function im = view(obj)
      % Acquire a single frame from the device
%       im = snapshot(obj.device);
        im = getsnapshot(obj.device);
%       im = getdata(obj.device, 1, 'uint16');
    end
  end
end

