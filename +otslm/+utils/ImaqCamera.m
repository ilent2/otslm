classdef ImaqCamera < otslm.utils.Viewable
% Connect to a image acquisition toolbox (imaq) camera
% Inherits from :class:`Viewable`
%
% This call can be used to create a otslm.utils.Viewable instance for
% a videoinput source.  This requires the Image Acquisition Toolbox.
%
% Properties
%   - device -- imaq object for the camera
%
% See also ImaqCamera.

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
      %
      % cam = ImaqCamera(adaptor, id, ...) conntect to the specified
      % webcam camera.  For the device id, imaqhwinfo.
      %
      % For cameras that support multiple formats, a 'format' named
      % argument can be supplied with the format to use.
      
      % Parse inputs
      p = inputParser;
      p.addRequired('device_adaptor');
      p.addRequired('device_id');
      p.addParameter('format', []);
      p.parse(varargin{:});
      
      % Call base class constructor
      obj = obj@otslm.utils.Viewable();
      
      % Handle default value for supported formats
      format = p.Results.format;
      if isempty(format)
        device_info = imaqhwinfo(p.Results.device_adaptor, p.Results.device_id);
        format = device_info.SupportedFormats{1};
      end
      
      % Connect to the device
      obj.device = videoinput(p.Results.device_adaptor, ...
          p.Results.device_id, format);
      
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

