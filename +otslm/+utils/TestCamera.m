classdef TestCamera < otslm.utils.Viewable
% TESTCAMERA non-physical camera for viewing Test* Showable objects
%
% Methods
%   view()    show the image currently displayed on the linked device
%
% Properties
%   size      size of the output image
%   showable  the Showable object that this class is linked to
%   roisize   (Viewable) size of the regions of interest
%   roioffset (Viewable) offsets for the regions of interest
%   numroi    (Viewable) number of regions of interest
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties (SetAccess=protected)
    size              % Size of the output image
    showable          % The Test* showable object we are looking at
  end

  methods

    function obj = TestCamera(showable)
      % Construct a new TestCamera looking at a Test* Showable object

      % Call base constructor
      obj = obj@otslm.utils.Viewable();

      assert(isa(showable, 'otslm.utils.TestSlm') || ...
          isa(showable, 'otslm.utils.TestDmd'), ...
          'Showable object must be TestSlm or TestDmd');

      obj.showable = showable;

      % Calculate size of output by showing a dummy image
      showable.showComplex(zeros(showable.size));
      obj.size = size(obj.view());
     end

    function im = view(obj)
      % View the Test* Showable object's output in the far field

      % Disable range warning (SLM might have larger range)
      oldstate = warning('query', 'otslm:tools:visualise:range');
      warning('off', 'otslm:tools:visualise:range');

      p = 200;

      im = abs(otslm.tools.visualise(obj.showable.pattern, ...
          'method', 'fft', 'padding', p)).^2;

      % Crop image (remove padding)
      im = im(p+1:end-p, p+1:end-p);

      % Restore original range warning
      warning(oldstate);
    end
  end

end
