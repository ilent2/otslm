classdef (Abstract) Viewable < handle
% VIEWABLE represents objects that can be viewed (cameras)
%
% Methods (Abstract)
%   view()        Show an image from the device.
%
% Methods:
%   viewTarget()  Show an image of the target region from the device.
%       The default behaviour is just to call view().
%
% Properties (Abstract)
%   size          Size of the device [rows, columns]
%   roisize       Size of the target region [rows, columns]
%
% This is the interface that utility functions which request an
% image from the experiment/simulation use.  For declaring a new
% camera, you should inherit from this class and define the view method.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  methods (Abstract)
    view(obj)       % Acquire an image from the device
  end

  methods

    function obj = Viewable()
      obj.roisize = obj.size;
      obj.roioffset = [0, 0];
    end

    function im = viewTarget(obj)
      % View the target, applies a ROI to the result of view()

      % Acquire the image in the normal way
      im = obj.view();
      
      % Handle default roi properties
      if isempty(obj.roisize)
        obj.roisize = obj.size;
      end
      
      if isempty(obj.roioffset)
        obj.roioffset = [0,0];
      end

      % Crop the image to the ROI
      im = im(1+obj.roioffset(1):obj.roioffset(1)+obj.roisize(1), ...
          1+obj.roioffset(2):obj.roioffset(2)+obj.roisize(2));
    end

    function crop(obj, roi)
      % Crop the image to a specified ROI
      %
      %  obj.crop([rows cols yoffset xoffset])
      assert(all(roi(1:2) <= obj.size), ...
          'ROI must be smaller or equal to image size');
      obj.roisize = roi(1:2);
      obj.roioffset = roi(3:4);
    end
  end

  properties (SetAccess=protected)
    roisize     % Size of the region of interest [rows, columns]
    roioffset;  % Offset of region of interest [y, x]
  end

  properties (Abstract, SetAccess=protected)
    size        % Size of the device [rows, columns]
  end

end
