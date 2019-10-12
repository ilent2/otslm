% +SUPPORT Sub-package providing methods used in the GUIs
%
% Some of these things should probably be classes (bases UI classes).
% We could also adopt a model-view-control architechture, but for
% the things like simplePatternValueChange, we should probably have
% a base UI class (if it becomes possible in future Matlab versions).
%
% Files
%   calculateImageSliceFreq    - Calculate the frequency spectrum of an image slice
%   checkImagesChanged         - Compare two cell arrays of images for changes
%   cleanTimer                 - Cleans up the timer when the app is about to finish
%   complexPatternValueChanged - simplePatternValueChanged common code for simple update uis with ptype
%   findTabUserdata            - Find entries with the specific user-data tag and returns a struct
%   getDeviceFromBase          - getDeviceFromBase get an showable object from the base workspace
%   getImageOrNone             - Get the image from the base workspace or an empty array
%   iterPatternValueChanged    - iterPatternValueChanged common code for iter update uis
%   populateDeviceList         - Populates the device list with Showable devices
%   saveVariableToBase         - saves the variables to the base workspace
%   simplePatternValueChanged  - simplePatternValueChanged common code for simple update uis
%   updateComplexDisplay       - updateComplexDisplay helper for the display on simple uis with ptype
%   updateIterDisplay          - updateSimpleDisplay helper for updating the display on iterative uis
%   updateSimpleDisplay        - updateSimpleDisplay helper for updating the display on simple uis
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.
