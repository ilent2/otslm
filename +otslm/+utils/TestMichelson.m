classdef TestMichelson < otslm.utils.Viewable
% TESTMICHELSON non-physical representation of Michelson interferometer
%
% Properties (read-only):
%   size      Size of the output image (same as Showable)
%   showable  The TestShowable device to image
%
% Properties:
%   tilt      Angle to tilt the showable device with respect to the
%       reference beam.  Applies a exp(2*pi*i*linear*tilt) grating.
%
% See also otslm.utils.TestShowable and otslm.utils.TestCamera
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties (SetAccess=protected)
    size        % Size of the output image
    showable    % The Test* showable object we are looking at
  end

  properties
    tilt        % Tilt of the device (default 0.0)
  end

  methods

    function obj = TestMichelson(showable)
      % Create the new interferometer-like device
      
      % Call base constructor
      obj = obj@otslm.utils.Viewable();
      
      obj.showable = showable;
      obj.size = showable.size;
      obj.tilt = 0.0;
    end

    function im = view(obj)
      % View the Test* showable object through a interferometer

      % Get the complex pattern
      pattern = obj.showable.pattern;

      % Apply the tilt
      grating = otslm.simple.linear(size(pattern), size(pattern, 2));
      pattern = pattern .* exp(2*pi*1i*grating*obj.tilt);

      % Generate the output image
      im = abs(ones(obj.showable.size) + pattern).^2;
    end

  end

end
