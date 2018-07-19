% +OTSLM/+UTILS utility functions for controlling, interacting with
% and simulating hardware
%
% Files
%   calibrate     - method to calibrate phase-only SLM
%   image_device  - method to generate image of slm
%   load_colormap - loads a colormap from file, colormaps can be used
%
% Base classes of showable and viewable objects
%   Showable      - represents devices that can display a pattern
%   Viewable      - represents objects that can be viewed (cameras)
%
% Physical devices
%   ScreenDevice  - represents a device controlled by full screen window
%   GigeCamera    - connect to a gige camera connected to the computer
%
% Non-physical devices used for testing
%   TestDmd       - non-physical dmd-like device for testing code
%   TestSlm       - non-physical slm-like device for testing code
%   TestCamera    - non-physical camera for viewing Test* Showable objects
%   TestMichelson - non-physical representation of Michelson interferometer
%   TestShowable  - non-physical showable device for testing implementation

