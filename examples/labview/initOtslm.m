function initOtslm()
% Initialize function for labview (adds toolbox path)

  fname = mfilename('fullpath');
  [fpath, ~, ~] = fileparts(fname);
  fparts = split(fpath, filesep);

  toolbox_path = fullfile(fparts{1:end-2});

  addpath(toolbox_path);

end

