function guess = simulated_annealing(target, varargin)
% SIMULATED_ANNEALING change multiple pixels 
%
% This method chooses a new pixel value for each pixel according to
% a normal distribution centred at the old pixel value.  The width
% of the distribution reduces as the temperature reduces.
%
% TODO: We could also choose uniform random values for the pixels
% and change the number of pixels we change each time.
%
% Optional named inputs:
%
%   'guess'       guess     Initial guess for phase
%   'incident'    incident  Incident illumination
%   'levels'      levels    Number of pixel levels in range -pi to pi.`
%       Can also be an array of pixel values.  If no levels are
%       supplied, the pattern is assumed to be continuous.  Default: [].
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('guess', []);
p.addParameter('incident', []);
p.addParameter('vismethod', 'fft');
p.addParameter('levels', []);
p.addParameter('objective', @otslm.iter.objectives.flatintensity);
p.addParameter('iterations', 1000);
p.addParameter('show_progress', true);
p.addParameter('maxT', 1000);
p.addParameter('initialT', 300);
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
  if ~isempty(lookuptable)
    guess = interp1(lookuptable, lookuptable, guess, 'nearest');
    guess(isnan(guess)) = lookuptable(1);
  end
end

% Setup the figure for progress
if p.Results.show_progress
  hf = figure();
  h = axes(hf);
  plt = plot(h, 0, 0);
  xlabel('Iteration');
  ylabel('Fitness');
  title('Simulated annealing progress');

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

% Calculate the original fitness
trial = otslm.tools.visualise(guess, 'method', p.Results.vismethod, ...
    'incident', p.Results.incident, ...
    'padding', p.Results.padding, 'trim_padding', true);
oldFitness = p.Results.objective(target, trial);

fitnessScores = zeros(p.Results.iterations+1, 1);
fitnessScores(1) = oldFitness;

noisescale = @(T) 1*T/p.Results.maxT;

ii = 0;
while ii <= p.Results.iterations && figure_active()

  ii = ii + 1;

  % Calculate temperature
  T = p.Results.initialT*(p.Results.iterations - ii + 1)/p.Results.iterations;

  % Generate a new random pattern
  newGuess = guess + randn(size(guess)).*noisescale(T);

  % Calculate the resulting field
  trial = otslm.tools.visualise(newGuess, 'method', p.Results.vismethod, ...
      'incident', p.Results.incident, ...
      'padding', p.Results.padding, 'trim_padding', true);

  % Calculate the fitness
  fitness = p.Results.objective(target, trial);

  % Determine if this trial is satisfactory to keep
  if fitness < oldFitness || exp(-(fitness-oldFitness)/T) < rand()
    guess = newGuess;
    oldFitness = fitness;
  end

  fitnessScores(ii+1) = fitness;

  % Report the current fitness
  if p.Results.show_progress
    plt.XData = 1:ii+1;
    plt.YData = fitnessScores(1:ii+1);
    drawnow;
  end

end

end

