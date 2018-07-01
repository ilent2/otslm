% Script to package the user interface into matlab packages
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

dirs = {'tools', 'simple', 'utils', 'iter'};

for d = dirs
  files = dir(['../guifiles/', d{1}, '/*.xml']);

  if isempty(files)
    continue;
  end

  % Make the output directory
  [~,~] = mkdir(d{1});

  for f = files

    % Copy file to package
    fname = fullfile(f.folder, f.name);
    [~,~] = mkdir('../guifiles/meta/matlab');
    copyfile(fname, '../guifiles/meta/matlab/document.xml');

    % Zip up files
    appname = [f.name(1:find(f.name == '.', 1, 'last')), 'mlapp'];
    apptarget = ['./', d{1}, '/', appname];
    zip(apptarget, '*', '../guifiles/meta');
    movefile([apptarget, '.zip'], apptarget);

  end

end
