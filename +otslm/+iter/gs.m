function pattern = gs(target, varargin)
% GS Gerchberg-Saxton algorithm
%
% pattern = gs(target, ...) attempts to recreate the target using
% the Gerchberg-Saxton algorithm.
%
% Optional named inputs:
%
%   'guess'       guess     Initial guess for phase
%   'incident'    incident  Incident illumination
%   'iterations'  num       Number of iterations to run

p = inputParser;
p.addParameter('guess', []);
p.addParameter('incident', ones(size(target)));
p.addParameter('iterations', 30);
p.parse(varargin{:});

% If no guess supplied, use ifft of target
guess = p.Results.guess;
if isempty(guess)
  guess = ifft(target);
else
  guess = exp(1i*guess);
end

% Iterate to find a solution
for ii = 1:p.Results.iterations
  B = abs(p.Results.incident) .* exp(1i*angle(guess));
  C = fft(B);
  D = abs(target) .* exp(1i*angle(C));
  guess = ifft(D);
end

% Calculate the phase of the result
pattern = angle(guess);

