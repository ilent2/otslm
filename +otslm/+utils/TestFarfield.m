classdef TestFarfield < otslm.utils.Viewable
% TESTFARFIELD non-physical camera for viewing Test* Showable objects
%
% Calcualtes the paraxial far-field of the Showable object.
%
% Methods
%   view()    show the image currently displayed on the linked device
%
% Properties
%   size      size of the output image
%   showable  the Showable object that this class is linked to
%   NA        numerical aperture of the lens
%   offset    offset from the focal plane of the lens
%   roisize   (Viewable) size of the regions of interest
%   roioffset (Viewable) offsets for the regions of interest
%   numroi    (Viewable) number of regions of interest
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties
    NA                % numerical aperture of the lens
    offset            % offset from the focal plane of the lens
  end

  properties (SetAccess=protected)
    size              % Size of the output image
    showable          % The Test* showable object we are looking at
  end

  methods (Static, Hidden)

    function validateShowable(showable)
      assert(isa(showable, 'otslm.utils.Showable'), ...
          'Showable object must be a otslm.utils.Showable');
    end

    function validateNA(NA)
      assert(isscalar(NA), 'Numerical aperture must be scalar');
    end

    function validateOffset(offset)
      assert(isscalar(offset), 'Offset must be scalar');
    end

  end

  methods

    function obj = TestFarfield(varargin)
      % Construct a new TestFarfield looking at a Test* Showable object
      %
      % obj = TestFarfield(showable, ...)
      %
      % Optional named arguments:
      %   NA     num     Numerical aperture of lens (default: 1.0)
      %   offset num     Offset from focal plane of lens (default: 0.0)

      % Call base constructor
      obj = obj@otslm.utils.Viewable();

      p = inputParser;
      p.addRequired('showable', @obj.validateShowable);
      p.addParameter('NA', 1.0, @obj.validateNA);
      p.addParameter('offset', 0.0, @obj.validateOffset);
      p.parse(varargin{:});

      % Store optional arguments
      obj.showable = p.Results.showable;
      obj.NA = p.Results.NA;
      obj.offset = p.Results.offset;

      % Calculate size of output by showing a dummy image
      obj.showable.showComplex(ones(obj.showable.size));
      obj.size = size(obj.view());
     end

    function im = view(obj)
      % View the Test* Showable object's output in the far field

      % Calculate paraxial approximation of far-field
      im = abs(otslm.tools.visualise(obj.showable.pattern, ...
          'method', 'fft', ...
          'padding', ceil(size(obj.showable.pattern)/2), ...
          'trim_padding', true, ...
          'NA', obj.NA, 'z', obj.offset)).^2;
    end
    
    function set.NA(obj, val)
      obj.validateNA(val);
      obj.NA = val;
    end
    
    function set.offset(obj, val)
      obj.validateOffset(val);
      obj.offset = val;
    end
  end

end
