% +OTSLM/+UTILS utility functions for controlling, interacting with
% and simulating hardware
%
% Classes
%   LookupTable   - represents the phase and pixel values of a lookup table
%
% Sub-packages
%   imaging       - functions for imaging the device surface
%   calibration   - functions for calibrating a device
%   RedTweezers   - interface for RedTweezers
%
% Base classes of showable and viewable objects
%   Showable      - represents devices that can display a pattern
%   Viewable      - represents objects that can be viewed (cameras)
%
% Physical devices
%   ScreenDevice  - represents a device controlled by a window on the screen
%   GigeCamera    - connect to a gige camera connected to the computer
%   WebcamCamera  - connect to a webcam camera connected to the computer
%   ImaqCamera    - connect to a image acquisition toolbox camera
%
% Non-physical devices used for testing
%   TestDmd       - non-physical dmd-like device for testing code
%   TestSlm       - non-physical slm-like device for testing code
%   TestFarfield  - non-physical camera for viewing Test* Showable objects
%   TestMichelson - non-physical representation of Michelson interferometer
%   TestShowable  - non-physical showable device for testing implementation
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.
