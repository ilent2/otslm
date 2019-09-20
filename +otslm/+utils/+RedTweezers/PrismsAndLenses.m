classdef PrismsAndLenses % < otslm.utils.RedTweezers.RedTweezers
  %PrismsAndLenses Prisms and Lenses algorithm for RedTweezers
  %
  % Implements the Prisms and Lenses algorithm in an OpenGl shader.
  %
  % Copyright 2018 Isaac Lenton
  % This file is part of OTSLM, see LICENSE.md for information about
  % using/distributing this file.
  
  properties
    num_spots     % number of spots in the pattern
  end
  
  methods
    function rt = RedTweezers(address, port)