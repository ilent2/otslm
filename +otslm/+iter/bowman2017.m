function pattern = bowman2017(target, varargin)
% BOWMAN2017 wrapper for Bowman 2017 conjugate gradient implementation
%
% pattern = bowman2017(target, ...) attempt to generate the target
% using a phase pattern optimised using conjugate gradient method.
%
% See Bowman, et al. Optics Express 25, 11692 (2017)
% If you use this method, please consider citing Bowman 2017.
%
% Optional named parameters:
%   'guess'   pattern   Initial guess at the phase
%   'iterations' num    Number of iterations (default: 200)
%   'steepness'  num    Steepness for Bowman cost function (default: 9.0)
%   'incident'  pattern Incident illumination (default: ones)
%   'roisize'    num    Optimisation region size (default: min(size)/2)
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('guess', []);
p.addParameter('iterations', 200);
p.addParameter('steepness', 9.0);
p.addParameter('incident', ones(size(target)));
p.addParameter('roisize', min(size(target))/2);
p.parse(varargin{:});

% Get the directory for the python library
[ourPath, ~, ~] = fileparts(mfilename('fullpath'));
pypath = fullfile(ourPath, 'bowman2017');

% Get or generate guess phase
% Use the guess described in the Bowman 2017 without translation
guess = p.Results.guess;
if isempty(guess)

  curv = 3.0;   % curvature of guess phase in mrad px^-2 (R)

  asp = 0.5;
  R = curv/1000;

  [xx, yy] = otslm.simple.grid(size(target));
  guess = 3*R*(asp.*(xx.^2) + (1-asp).*(yy.^2));

end

% % Allow python to interact with us
% if ~matlab.engine.isEngineShared
%   matlab.engine.shareEngine;
% end

% Create a structure to store the relevent data
data = struct();
data.target = target;
data.incident = p.Results.incident;
data.roisize = p.Results.roisize;
data.steepness = p.Results.steepness;
data.guess = guess;
data.iterations = p.Results.iterations;

%% Method 1: Call the python wrapper for the method
%
% % Add the python library to the python path
% if count(py.sys.path,pypath) == 0
%     insert(py.sys.path,int32(0),pypath);
% end
%
% To get this to work, I needed to remove _session = EngineSession() in
% /usr/lib/python2.7/site-packages/matlab/engine    (R2018a)
%
% This still doesn't work, for some reason numpy and other libs wont import
%
%pattern = py.wrapper.run(py.list(size(target)), py.list(target(:).'), ...
%    py.list(p.Results.incident(:).'), p.Results.roisize, p.Results.steepness, ...
%    py.list(guess(:).'), p.Results.iterations);

%% Method 2: Start a new python process that hooks into matlab
% Doesn't work, since we need to release the engine lock
% 
% % Put the structure in the global workspace
% dataname = 'bowman2017data';
% assignin('base', dataname, data);
% 
% wrapper = fullfile(pypath, 'wrapper.py');
% system(['python ', wrapper, ' ', matlab.engine.engineName]);
% 
% % Get the result and clean up the data
% pattern = evalin('base', [dataname, '.pattern']);
% evalin('base', ['clear ', dataname]);

%% Method 3: write the data to a mat file and read it in python

% Save the data to a file
dataname = [tempname, '.mat'];
save(dataname, '-struct', 'data');

% Call python with our data file
wrapper = fullfile(pypath, 'wrapper.py');
system(['python ', wrapper, ' ', dataname]);

% Get the data from the file and clean up
pattern = load(dataname, 'pattern');
pattern = pattern.pattern;
delete(dataname);

