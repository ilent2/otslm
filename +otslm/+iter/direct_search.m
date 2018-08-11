function guess = direct_search(target, varargin)
% DIRECT_SEARCH search through each pixel value to optimise hologram
%
% The algorithm is described in
% Di Leonardo, et al., Opt. Express 15, 1913-1922 (2007)
%
% Optional named inputs:
%
%   'guess'       guess     Initial guess for phase
%   'incident'    incident  Incident illumination
%   'levels'      levels    Number of pixel levels in range -pi to pi.`
%       Can also be an array of pixel values.  Default: 256.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('guess', []);
p.addParameter('incident', []);
p.addParameter('vismethod', 'fft');
p.addParameter('levels', 256);
p.addParameter('objective', @otslm.iter.objectives.flatintensity);
p.addParameter('iterations', 100);
p.addParameter('show_progress', true);
p.addParameter('padding', round(max(size(target))/2));
p.parse(varargin{:});

% Generate lookup table if required
lookuptable = p.Results.levels;
if isscalar(p.Results.levels)
  lookuptable = ((1:p.Results.levels) - 1)*2*pi/p.Results.levels - pi;
end

% Generate guess if required
guess = p.Results.guess;
if isempty(guess)
  guess = angle(otslm.tools.visualise(complex(target), 'method', 'fft', ...
      'padding', p.Results.padding, 'trim_padding', true, ...
      'type', 'nearfield'));
  guess = interp1(lookuptable, lookuptable, guess, 'nearest');
  guess(isnan(guess)) = lookuptable(1);
end

% Setup the figure for progress
if p.Results.show_progress
  hf = figure();
  h = axes(hf);
  plt = plot(h, 0, 0);
  xlabel('Iteration');
  ylabel('Fitness');
  title('Direct search progress');
  
  % Create a stop button
  btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Stop',...
      'Position', [20 20 50 20]);  
  btn.Enable = 'Inactive';
  btn.UserData = true;
  btn.ButtonDownFcn = @(src, event) set(btn, 'UserData', false);
  drawnow;
  
  figure_active = @() ishandle(hf) && btn.UserData;
else
  figure_active = @() true;
end

fitnessScores = zeros(p.Results.iterations, 1);

ii = 0;
while (p.Results.iterations ~= 0 && ii <= p.Results.iterations) ...
    && figure_active()
  
  ii = ii + 1;

  % Pick a random pixel location
  loc = randi(numel(guess), 1);

  % Try all values for this pixel
  fitness = zeros(numel(lookuptable, 1));
  for jj = 1:numel(lookuptable)

    % Change the pixel value
    guess(loc) = lookuptable(jj);

    % Calculate the resulting field
    trial = otslm.tools.visualise(guess, 'method', p.Results.vismethod, ...
        'incident', p.Results.incident, 'padding', p.Results.padding, ...
        'trim_padding', true);

    % Calculate the fitness
    fitness(jj) = p.Results.objective(target, trial);

  end

  % Update the guess
  [bestFittness, I] = min(fitness);
  guess(loc) = lookuptable(I);
  fitnessScores(ii) = bestFittness;

  % Report the current fitness
  if p.Results.show_progress
    plt.XData = 1:ii;
    plt.YData = fitnessScores(1:ii);
    drawnow;
  end

end

end

