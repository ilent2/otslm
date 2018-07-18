classdef GigeCamera < otslm.utils.Viewable
%GIGECAMERA connect to a gige camera connected to the computer
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.
  
  properties (SetAccess=protected)
    device      % The physical device (gige object)
    size        % Resolution of the device
  end
  
  methods
    function obj = GigeCamera(varargin)
      % Connect to the camera
      
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
  end
end

