classdef GigeCamera < otslm.utils.Viewable
% Connect to a gige camera connected to the computer
% Inherits from :class:`Viewable`.
%
% Properties
%   - device   -- gige camera object
%   - size     -- size of the camera output image
%   - Exposure -- camera exposure setting
%
% See also GigeCamera

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties (SetAccess=protected)
    device      % The physical device (gige object)
    size        % Resolution of the device
  end

  properties (Dependent=true)
    Exposure     % Camera exposure
    %Gain         % Camera Gain
  end

  methods
    function obj = GigeCamera(varargin)
      % Connect to the camera
      %
      % cam = GigeCamera(device_id)
      % connects to the specified GIGE camera.
      % device_id is passed to the gigecam function.
      
      % Parse inputs
      p = inputParser;
      p.addRequired('device_id');
      p.parse(varargin{:});
      
      % Call base class constructor
      obj = obj@otslm.utils.Viewable();
      
      % Connect to the device
      obj.device = gigecam(p.Results.device_id);
      
      % Acquire the device size
      width = obj.device.Width;
      height = obj.device.Height;
      obj.size = [height, width];
    end
    
    function delete(obj)
      % Ensure the camera is closed on exit
      delete(obj.device);
    end
    
    function im = view(obj)
      % Acquire a single frame from the device
      im = snapshot(obj.device);
    end
    
    function set.Exposure(cam, val)
      cam.device.ExposureTimeAbs = val;
    end
    
    function val = get.Exposure(cam)
      val = cam.device.ExposureTimeAbs;
    end
    
  end
end

