classdef TestCamera < otslm.utils.Viewable
% TESTCAMERA non-physical camera object for viewing Test* Showable objects
%
% TODO: This functionality should be combined with TestDmd and TestSlm,
%   i.e. these device should inherit from Viewable too
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

      assert(isa(showable, 'otslm.utils.TestSlm') || ...
          isa(showable, 'otslm.utils.TestDmd'), ...
          'Showable object must be TestSlm or TestDmd');

      obj.showable = showable;

      % Calculate size of output by showing a dummy image
      showable.showComplex(zeros(showable.size));
      obj.size = size(showable.output);
     end

    function im = view(obj)
      % View the Test* Showable object's output
      im = obj.showable.output;
    end
  end

end
