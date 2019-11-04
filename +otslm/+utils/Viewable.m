classdef (Abstract) Viewable < handle
% Abstract representation of objects that can be viewed (cameras).
% Inherits from :class:`handle`.
%
% Methods (Abstract)
%  - view()        Show an image from the device.
%
% Methods
%  - viewTarget()  Show an image of the target region from the device.
%    The default behaviour is just to call view().
%  - crop(roi)     Create a region of interest that is returned by
%    viewTarget.  Can have multiple regions.
%
% Properties (Abstract)
%  - size          Size of the device [rows, columns]
%  - roisize       Size of the target region [rows, columns]
%
% This is the interface that utility functions which request an
% image from the experiment/simulation use.  For declaring a new
% camera, you should inherit from this class and define the view method.

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

    function varargout = viewTarget(obj, varargin)
      % View the target, applies a ROI to the result of view()
      %
      % im = viewTarget(...) acquire one or more target regions and
      % return them to an cell array of images.  Specify target
      % regions using the crop function.  If no output is requiested,
      % the image will be displayed in the current axes.
      %
      % Optional named arguments
      %   - roi     array     Specified which roi to return
      %
      % See also otslm.Viewable.crop.

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
      
      % Display result if no output requested
      if nargout == 0 && ~iscell(im)
        imagesc(im);
      else
        varargout{1} = im;
      end
    end

    function crop(cam, roi)
      % Crop the image to a specified ROI
      %
      % cam.crop([]) resets the roi to the full screen.
      %
      % cam.crop(rect) creates a single region of
      % interest described by the rect [xmin ymin width height].
      %
      % cam.crop({rect1, rect2, ...}) creates multiple regions of
      % interest described by separate rects.
      
      % Old format: [height width ymin xmin]

      if isempty(roi)
        cam.roioffset = [0,0];
        cam.roisize = cam.size;
        return;
      elseif ~iscell(roi)
        roi = {roi};
      end

      cam.roisize = zeros(numel(roi), 2);
      cam.roioffset = zeros(numel(roi), 2);

      for ii = 1:numel(roi)
        
        % Check type and size of rect
        assert(all(roi{ii} == round(roi{ii})), ...
          'all rect values must be integer');
        assert(numel(roi{ii}) == 4, ...
          'rect must be 4 element vector');
        
        % Check ROI is within device size
        assert(all(roi{ii}(1:2) >= 0), ...
          'xmin/ymin must be greater or equal to zero');
        assert(all(roi{ii}(1:2) + roi{ii}(3:4) <= cam.size(2:-1:1)), ...
            'ROI must be within device image');
          
        % Store the ROI
        cam.roisize(ii, :) = roi{ii}(4:-1:3);
        cam.roioffset(ii, :) = roi{ii}(2:-1:1);
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
