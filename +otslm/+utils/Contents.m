% +OTSLM/+UTILS utility functions for controlling, interacting with
% and simulating hardware
%
% Files
%   calibrate     - method to calibrate phase-only SLM
%   find_roi      - method to find region of camera SLM projects onto
%   FrameReader   - non-physical slm/camera, reads frames from a file
%   image_device  - method to generate image of slm
%   load_colormap - loads a colormap from file, colormaps can be used
%   ScreenDevice  - represents a device controlled by full screen window
%   Showable      - represents objects that can be used to change the beam (slm/dmds)
%   TestCamera    - non-physical camera object for viewing Test* Showable objects
%   TestDmd       - non-physical dmd-like device for testing code
%   TestSlm       - non-physical slm-like device for testing code
%   Viewable      - represents objects that can be viewed (cameras)
