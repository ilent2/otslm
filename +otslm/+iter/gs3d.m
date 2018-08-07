function pattern = gs3d(target, varargin)
% GS3D 3-D Gerchberg-Saxton algorithm and Adaptive-Adaptive algorithm
%
% pattern = gs(target, ...) attempts to recreate the target volume using
% the 3-D analog of the Gerchberg-Saxton algorithm.
%
% See Hao Chen et al 2013 J. Opt. 15 035401
%  and Graeme Whyte and Johannes Courtial 2005 New J. Phys. 7 117
%
% Optional named inputs:
%
%   'guess'       guess     Initial guess for phase
%   'incident'    incident  Incident illumination
%   'iterations'  num       Number of iterations to run
%   'adaptive'    factor    Factor for Adaptive-Adaptive algorithm
%       If the factor is 1 (default), the algorithm becomes GS.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('guess', []);
p.addParameter('incident', ones(size(target)));
p.addParameter('iterations', 30);
p.addParameter('adaptive', 1.0);
p.addParameter('focal_length', min([size(target, 1), size(target, 2)])/2);
p.addParameter('padding', 0);
p.addParameter('show_progress', true);
p.parse(varargin{:});

incident = p.Results.incident;

% TODO: This includes duplication with ott.tools.visualise, merge?
% TODO: There is also duplication with ott.tools.gs, merge?
% TODO: Allow user to select fitness function

% Handle multiple padding arguments
if numel(p.Results.padding) == 1
  xpadding = p.Results.padding;
  ypadding = p.Results.padding;
  zpadding = p.Results.padding;
elseif numel(p.Results.padding) == 2
  xpadding = p.Results.padding(1);
  ypadding = p.Results.padding(1);
  zpadding = p.Results.padding(2);
elseif numel(p.Results.padding) == 3
  xpadding = p.Results.padding(1);
  ypadding = p.Results.padding(2);
  zpadding = p.Results.padding(3);
end

% Calculate the lens range without padding
zlimit = size(target, 3) - 2*zpadding;

% Setup the figure for progress
if p.Results.show_progress
  hf = figure();
  h = axes(hf);
  plt = semilogy(h, 1, 1);
  xlabel('Iteration');
  ylabel('Fitness');
  title('GS3D progress');

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

% Assume the target already has padding
% Check if the incident array needs padding
if size(incident, 1) + 2*ypadding == size(target, 1) ...
    && size(incident, 2) + 2*xpadding == size(target, 2)
  incident = padarray(incident, [ypadding, xpadding, 0], 0, 'both');
end

% Check that the incident array has the correct size
if size(incident, 1) ~= size(target, 1) ...
    || size(incident, 2) ~= size(target, 2)
  error('incident and target array must have same size on dims 1 and 2');
end

% Apply quadrant shift to target
target = fftshift(target);

% If no guess supplied, use ifft of target
guess = p.Results.guess;
if isempty(guess)
  guess = ifftn(target);
else
  guess = exp(1i*guess);
end

% Make sure the guess is a volume
if size(guess, 3) == 1
  guess = otslm.tools.hologram2volume(guess, ...
      'focal_length', p.Results.focal_length, ...
      'padding', zpadding, 'zlimit', zlimit);
end

fitnessScores = zeros(p.Results.iterations, 1);

% Iterate to find a solution
ii = 0;
while (p.Results.iterations ~= 0 && ii <= p.Results.iterations) ...
    && figure_active()

  ii = ii + 1;

  % Apply lens constraint to guess
  guessH = otslm.tools.volume2hologram(guess, ...
      'focal_length', p.Results.focal_length, ...
      'padding', zpadding);

  % Multiply by incident field and apply phase constraint
  guessH = abs(incident) .* exp(1i*angle(guessH));

  % Convert to volume and calculate generated pattern from guess
  output = fftn(otslm.tools.hologram2volume(guessH, ...
      'focal_length', p.Results.focal_length, ...
      'padding', zpadding, 'zlimit', zlimit));

  % Do adaptive-adaptive step
  a = p.Results.adaptive;
  targetAmplitude = a.*abs(target) + (1 - a).*abs(output)./numel(output);

  % Calculate new guess
  guess = ifftn(targetAmplitude .* exp(1i*angle(output)));

  % Report the current fitness
  if p.Results.show_progress

    % Calculate current fitness
    fitnessScores(ii) = sqrt(sum(abs(targetAmplitude(:)) - abs(output(:))./numel(output)).^2);

    % Update plot data
    plt.XData = 1:ii;
    plt.YData = fitnessScores(1:ii);
    drawnow;
  end

end

% Calculate the phase of the result
pattern = angle(otslm.tools.volume2hologram(guess, ...
      'focal_length', p.Results.focal_length, ...
      'padding', zpadding));

% Remove the padding from the results
pattern = pattern(1+ypadding:end-ypadding, 1+xpadding:end-xpadding);

