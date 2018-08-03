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
p.parse(varargin{:});

incident = p.Results.incident;

% TODO: Think about padding

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
  guess = otslm.tools.hologram2volume(guess);
end

% Iterate to find a solution
for ii = 1:p.Results.iterations
  
  % Apply lens constraint to guess
  guessH = otslm.tools.volume2hologram(guess);
  
  % Multiply by incident field and apply phase constraint
  guessH = abs(incident) .* exp(1i*angle(guessH));
  
  % Convert to volume and calculate generated pattern from guess
  output = fftn(otslm.tools.hologram2volume(guessH));

  % Do adaptive-adaptive step
  a = p.Results.adaptive;
  targetAmplitude = a.*abs(target) + (1 - a).*abs(output);

  % Calculate new guess
  guess = ifftn(targetAmplitude .* exp(1i*angle(output)));

end

% Calculate the phase of the result
pattern = angle(otslm.tools.volume2hologram(guess));

