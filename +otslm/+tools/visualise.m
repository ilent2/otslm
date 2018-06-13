function varargout = visualise(phase, varargin)
% VISUALISE generates far-field plane images of the phase pattern
%
% [output, ...] = visualise(phase, ...) visualise the phase plane.
% Some methods output additional parameters, such as the ott-toolbox beam.
%
% If phase is an empty array and one of the other images is supplied,
% the phase is assumed to be an array of zeros the same size as one of
% the other images.
%
% The phase image should be in a range from 0 to 2*pi.  If the range is
% approximately 1 a warning is issued.
%
% Optional named parameters:
%
%   'method'    method      Method to use when calculating visualisation.
%     Current supported methods:
%         'fft'         Use fourier transform approach described in
%                       https://doi.org/10.1364/JOSAA.15.000857
%         'ott'         Use optical tweezers toolbox
%
%   'amplitude' image     Specifies the amplitude pattern
%   'incident'  image     Specifies the incident illumination
%       Default illumination is a Gaussian beam (w0 = 0.25*min(size(phase))
%   'z'         z         z-position of output plane

p = inputParser;
p.addParameter('method', 'fft');
p.addParameter('amplitude', ones(size(phase)));
p.addParameter('incident', []);
p.addParameter('z', 0.0);
p.parse(varargin{:});

amplitude = p.Results.amplitude;
incident = p.Results.incident;

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
  [xx, yy] = meshgrid(1:size(phase, 2), 1:size(phase, 1));
  sigma = 0.25 * min(size(phase));
  incident = exp(-(xx.^2 + yy.^2)./(2*sigma^2));
  incident = incident ./ max(incident(:));
end

% Check sizes of input images
assert(all(size(incident) == size(phase)));
assert(all(size(amplitude) == size(phase)));

% Check phase range
if abs(max(phase(:)) - min(phase(:))) < eps(1)
  warning('Phase range should be 0 to 2*pi');
end

% Generate combined pattern
U = amplitude .* exp(1i*phase) .* incident;

switch p.Results.method
  case 'fft'
    varargout{1} = fft_method(U, p.Results.z);
  case 'ott'
    [varargout{1:length(varargout)}] = ott_method(U, p.Results.z);
  otherwise
    error('Unknown method');
end

end

function output = fft_method(U, z)
% z should be dimensionless, multiplied by a factor of 2pi/lambda

  [tx, ty] = meshgrid(1:size(U, 2), 1:size(U, 1));
  tx = tx - size(U, 2)/2;
  ty = ty - size(U, 1)/2;

  % Currently guessing a range for these values
  m = sqrt(tx(end, end)^2 + ty(end, end)^2);
  tx = tx ./ m .* (pi/2);
  ty = ty ./ m .* (pi/2);

  ax = sin(tx);
  ay = sin(ty);

  % Calculate the output plane
  output = ifft2(fft2(U) .* fftshift(exp(-1i*z*sqrt(1 - ax.^2 + ay.^2))));

end

function [output, beam] = ott_method(U, z)
  % TODO
  error('Not yet implemented');
end

