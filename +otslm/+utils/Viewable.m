classdef (Abstract) Viewable
% VIEWABLE represents objects that can be viewed (cameras)
%
% This is the interface that utility functions which request an
% image from the experiment/simulation use.  For declaring a new
% camera, you should inherit from this class and define the view method.

  methods (Abstract)
    view(obj)
  end

end
