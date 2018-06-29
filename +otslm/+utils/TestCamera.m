classdef TestCamera < otslm.utils.Viewable
% TestCamera non-physical camera object for viewing Test* Showable objects

  properties (SetAccess=protected)
    size = [512, 512];
    roisize = [512, 512];

    showable          % The Test* showable object we are looking at
  end

  methods

    function obj = TestCamera(showable)
      % Construct a new TestCamera looking at a Test* Showable object

      assert(isa(showable, 'otslm.utils.TestSlm') || ...
          isa(showable, 'otslm.utils.TestDmd'), ...
          'Showable object must be TestSlm or TestDmd');

      obj.showable = showable;
    end

    function im = view(obj)
      % View the Test* Showable object's output
      im = obj.showable.output;
    end
  end

end
