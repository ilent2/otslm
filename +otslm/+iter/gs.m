function pattern = gs(target, varargin)
% GS Gerchberg-Saxton algorithm and Adaptive-Adaptive algorithm
%
% pattern = gs(target, ...) attempts to recreate the target using
% the Gerchberg-Saxton algorithm.
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
p.addParameter('padding', 0);
p.parse(varargin{:});

% Add padding to inputs
target = padarray(target, p.Results.padding.*[1,1], 0, 'both');
incident = padarray(p.Results.incident, p.Results.padding.*[1,1], 0, 'both');

% Apply quadrant shift to target
target = fftshift(target);

% If no guess supplied, use ifft of target
guess = p.Results.guess;
if isempty(guess)
  guess = ifft2(target);
else
  guess = exp(1i*guess);
end

% Iterate to find a solution
for ii = 1:p.Results.iterations

  % Calculate generated pattern from guess
  B = abs(incident) .* exp(1i*angle(guess));
  output = fft2(B);

  % Do adaptive-adaptive step
  a = p.Results.adaptive;
  targetAmplitude = a.*abs(target) + (1 - a).*abs(output);

  % Calculate new guess
  D = targetAmplitude .* exp(1i*angle(output));
  guess = ifft2(D);

end

% Calculate the phase of the result
pattern = angle(guess);

% Remove padding from result
pattern = pattern(1+p.Results.padding:end-p.Results.padding, ...
    1+p.Results.padding:end-p.Results.padding);

