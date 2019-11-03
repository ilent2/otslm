% +OTSLM/+UTILS utility functions for controlling, interacting with
% and simulating hardware
%
% Classes
%   LookupTable   - Class representing the phase and pixel values of a lookup table.
%
% Sub-packages
%   imaging       - functions for imaging the device surface
%   calibration   - functions for calibrating a device
%   RedTweezers   - interface for RedTweezers
%
% Base classes of showable and viewable objects
%   Showable      - Represents devices that can display a pattern.
%   Viewable      - Abstract representation of objects that can be viewed (cameras).
%
% Physical devices
%   ScreenDevice  - Represents a device controlled by a window on the screen
%   GigeCamera    - Connect to a gige camera connected to the computer
%   WebcamCamera  - Connect to a webcam camera connected to the computer.
%   ImaqCamera    - Connect to a image acquisition toolbox (imaq) camera
%
% Non-physical devices used for testing
%   TestDmd       - Non-physical dmd-like device for testing code.
%   TestSlm       - Non-physical slm-like device for testing code.
%   TestFarfield  - Non-physical camera for viewing TestShowable objects
%   TestMichelson - Non-physical representation of Michelson interferometer.
%   TestShowable  - Non-physical showable device for testing implementation.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.
