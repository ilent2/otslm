function initOtslm()
% Initialize function for labview (adds toolbox path)
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  fname = mfilename('fullpath');
  [fpath, ~, ~] = fileparts(fname);
  fparts = split(fpath, filesep);
  
  % Add current path
  addpath(fpath);

  % Add toolbox path
  toolbox_path = fullfile(fparts{1:end-2});
  addpath(toolbox_path);

end

