function U = make_beam(phase, varargin)
% Combine the phase, amplitude and incident patterns.
%
% Usage
%   U = make_beam(phase, ...) converts the phase pattern with a 2*pi
%   range into a complex field amplitude.  If phase is already complex
%   the result is U = phase.
%
% Parameters
%   - phase (numeric) -- pattern to convert
%
% Named parameters
%   - incident (numeric) -- incident illumination.
%   - amplitude (numeric) -- specify amplitude of the field.  Only
%     used when phase is a real matrix.

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('amplitude', []);
p.addParameter('incident', []);
p.parse(varargin{:});

amplitude = p.Results.amplitude;
incident = p.Results.incident;

% Handle default value for amplitude
if isempty(amplitude) && ~isempty(phase)
  amplitude = ones(size(phase));
end

% Handle default value for phase
if isempty(phase)
  if ~isempty(amplitude)
    phase = zeros(size(amplitude));
  elseif ~isempty(incident)
    phase = zeros(size(incident));
    amplitude = ones(size(incident));
  else
    error('Must have at least one input image');
  end
end

% Handle default value for incident
if isempty(incident)
  psz = size(phase);
  incident = ones(psz(1:2));
end

% Ensure incident and amplitude are volumes if phase is a volume
if size(phase, 3) ~= size(incident, 3) && size(incident, 3) == 1
  incident = repmat(incident, [1, 1, size(phase, 3)]);
end
if size(phase, 3) ~= size(amplitude, 3) && size(amplitude, 3) == 1
  amplitude = repmat(amplitude, [1, 1, size(phase, 3)]);
end

% Check sizes of input images
assert(all(size(incident) == size(phase)), ...
  'Incident size must match phase size');
assert(all(size(amplitude) == size(phase)), ...
  'Amplitude size must match phase size');

% Allow the user to pass in a single complex amplitude or
% separate phase and amplitude matrices
if isreal(phase)

  % Check phase range
  if max(phase(:)) - min(phase(:)) <= 1 && ...
      abs(1 - max(phase(:)) - min(phase(:))) <= 0.1
    warning('otslm:tools:make_beam:range', 'Phase range should be 2*pi');
  end

  % Generate combined pattern
  U = amplitude .* exp(1i*phase) .* incident;

else

  if ~isempty(p.Results.amplitude)
    warning('otslm:tools:make_beam:amplitude_ignored', ...
        'Amplitude ignored in input');
  end

  % The input is a complex amplitude
  U = phase .* incident;

end

