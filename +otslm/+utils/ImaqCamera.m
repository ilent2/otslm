classdef ImaqCamera < otslm.utils.Viewable
%IMAQCAMERA connect to a image acquisition toolbox camera
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.
  
  properties (SetAccess=protected)
    device      % The physical device (videoinput object)
    size        % Resolution of the device
  end
  
  methods
    function obj = ImaqCamera(varargin)
      % Connect to the camera
      
      % Parse inputs
      p = inputParser;
      p.addRequired('device_adaptor');
      p.addRequired('device_id');
      p.parse(varargin{:});
      
      % Call base class constructor
      obj = obj@otslm.utils.Viewable();
      
      % Connect to the device
      obj.device = videoinput(p.Results.device_adaptor, p.Results.device_id);
      
      % Acquire the device size
      width = imaqhwinfo(obj.device, 'MaxWidth');
      height = imaqhwinfo(obj.device, 'MaxHeight');
      obj.size = [height, width];
    end
    
    function delete(obj)
      % Ensure the camera is closed on exit
      delete(obj.device);
    end
    
    function im = view(obj)
      % Acquire a single frame from the device
      im = getsnapshot(obj.device);
    end
  end
end

