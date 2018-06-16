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
%   'padding'   p         Add padding to the outside of the image.

p = inputParser;
p.addParameter('method', 'fft');
p.addParameter('type', 'farfield');
p.addParameter('amplitude', ones(size(phase)));
p.addParameter('incident', []);
p.addParameter('z', 0.0);
p.addParameter('padding', 100);
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
  xx = xx - size(phase, 2)/2;
  yy = yy - size(phase, 1)/2;
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
    varargout{1} = fft_method(U, p);
  case 'ott'
    [varargout{1:length(varargout)}] = ott_method(U, p);
  otherwise
    error('Unknown method');
end

end

function output = fft_method(U, p)
% z should be dimensionless, multiplied by a factor of 2pi/lambda

  z = p.Results.z;
  padding = p.Results.padding;

  if strcmpi(p.Results.type, 'farfield')

    % Apply padding to the image
    img = zeros(size(U)+2*[padding, padding]);
    img(padding+(1:size(U, 1)), padding+(1:size(U, 2))) = U;
    U = img;

    % This should work, perhaps x and y are the wrong size
    %[tx, ty] = meshgrid(1:size(U, 2), 1:size(U, 1));
    %tx = tx - size(U, 2)/2;
    %ty = ty - size(U, 1)/2;
    %x = tx ./ size(U, 2);
    %y = ty ./ size(U, 1);
    %lambda = 1e-6;
    %d = 1.0;
    %f = (1.0 + z)*d;
    %output = exp(i*pi*(1 - d/f).*(x.^2 + y.^2)/(lambda*f)) ...
    %    .* fftshift(fft2(U));

    % Transform to the focal plane (missing scaling factor)
    output = fftshift(fft2(U));

    [tx, ty] = meshgrid(1:size(U, 2), 1:size(U, 1));
    tx = tx - size(U, 2)/2;
    ty = ty - size(U, 1)/2;

    % Currently guessing a range for these values
    tx = tx ./ size(U, 2);
    ty = ty ./ size(U, 1);

    ax = sin(tx);
    ay = sin(ty);

    % Shift the plane in the z direction
    output = ifft2(fft2(output) .* ...
        fftshift(exp(-1i*z*sqrt(1 - ax.^2 + ay.^2))));

    % TODO: z-shift should be its own function

  elseif strcmpi(p.Results.type, 'nearfield')

    % TODO: inverse z-shift

    % Calculate pattern at DOE
    output = ifft2(fftshift(U)));

  end
end

function [output, beam] = ott_method(U, z)
  % TODO
  error('Not yet implemented');
end

