classdef TestMichelson < otslm.utils.Viewable
% Non-physical representation of Michelson interferometer.
% Inherits from :class:`Viewable`.
%
% The interferometer consists of two arms, a reference arm with a mirror
% and a device arm with a ``Showable`` device such as a SLM or DMD
% The TestMichelson simulates a :class:`TestShowable` device placed
% in one arm, and calculates the interference pattern between the
% reference arm and the test arm.
%
% The ``view`` function gets the current ``pattern`` from the
% ``TestShowable`` device and calculates the interference.
% The device supports adding a tilt between the reference arm and the
% Showable arm.  This can be useful for
% testing :func:`calibration.smichelson`.
%
% Properties
%  - tilt     -- Angle to tilt the showable device with respect to the
%    reference beam.  Applies a exp(2*pi*i*linear*tilt) grating.
%
% Properties (read-only)
%  - size     -- Size of the output image (same as Showable)
%  - showable -- The TestShowable device
%
% See also TestMichelson, :class:`TestShowable` and :class:`TestFarfield`.

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

    function obj = TestMichelson(showable, varargin)
      % Create the new interferometer-like device
      %
      % Usage
      %   obj = TestMichelson(showable, ...) construct a new Michelson
      %   interferometer to view the TestShowable device.
      %
      % Parameters
      %   - showable (:class:`TestShowable`) -- the device to link
      %
      % Optional named arguments
      %   - tilt (numeric) -- tilt factor (default: 0.0)

      p = inputParser;
      p.addParameter('tilt', 0.0);
      p.parse(varargin{:});
      
      % Call base constructor
      obj = obj@otslm.utils.Viewable();
      
      obj.showable = showable;
      obj.size = showable.size;
      obj.tilt = p.Results.tilt;
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
