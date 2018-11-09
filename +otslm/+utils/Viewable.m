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

    function im = viewTarget(obj, varargin)
      % View the target, applies a ROI to the result of view()
      %
      % im = viewTarget(...)
      %
      % Optional named arguments:
      %   roi     array     Specified which roi to return

      p = inputParser;
      p.addParameter('roi', 1);
      p.parse(varargin{:});

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
      if ~isempty(p.Results.roi)
        oim = im;
        im = cell(1, numel(p.Results.roi));
        for ii = 1:numel(p.Results.roi)
          idx = p.Results.roi(ii);
          im{ii} = oim(1+obj.roioffset(idx, 1):obj.roioffset(idx, 1)+obj.roisize(idx, 1), ...
              1+obj.roioffset(idx, 2):obj.roioffset(idx, 2)+obj.roisize(idx, 2));
        end

        if length(im) == 1
          im = im{1};
        end
      end
    end

    function crop(obj, roi)
      % Crop the image to a specified ROI
      %
      %  obj.crop([]) resets the roi to the full screen.
      %
      %  obj.crop([rows cols yoffset xoffset])

      % TODO: Make input consistent with the getrect function

      if isempty(roi)
        obj.roioffset = [0,0];
        obj.roisize = obj.size;
        return;
      elseif ~iscell(roi)
        roi = {roi};
      end

      obj.roisize = zeros(numel(roi), 2);
      obj.roioffset = zeros(numel(roi), 2);

      for ii = 1:numel(roi)
        assert(all(roi{ii}(1:2) <= obj.size), ...
            'ROI must be smaller or equal to image size');
        obj.roisize(ii, :) = roi{ii}(1:2);
        obj.roioffset(ii, :) = roi{ii}(3:4);
      end
    end

    function num = get.numroi(obj)
      % Get the number of ROIs that have been set
      num = size(obj.roisize, 1);
    end
  end

  properties (SetAccess=protected)
    roisize     % Size of the region of interest [rows, columns]
    roioffset;  % Offset of region of interest [y, x]
  end

  properties (Abstract, SetAccess=protected)
    size        % Size of the device [rows, columns]
  end

  properties (Dependent)
    numroi      % Number of ROI that have been set
  end

end
