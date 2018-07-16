function varargout = visualise(phase, varargin)
% VISUALISE generates far-field plane images of the phase pattern
%
% [output, ...] = visualise(phase, ...) visualise the phase plane.
% Some methods output additional parameters, such as the ott-toolbox beam.
%
% [output, ...] = visualise(complex_amplitude, ...) visualise the
% plane 
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
%         'rs'          Rayleigh-Sommerfeld diffraction formula
%         'rslens'      Use rs to propagate to a lens, apply the lens
%             phase pattern and propagate some distance from the lens.
%
%   'type'      type      Type of transformation: 'nearfield' or 'farfield'
%
%   'amplitude' image     Specifies the amplitude pattern
%   'incident'  image     Specifies the incident illumination
%       Default illumination is a Gaussian beam (w0 = 0.25*min(size(phase))
%   'z'         z         z-position of output plane.  For fft/ott this
%       is an offset from the focal plane.  For rs/rslens, this is the
%       distance along the beam axis.
%   'padding'   p         Add padding to the outside of the image.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('method', 'fft');
p.addParameter('type', 'farfield');
p.addParameter('amplitude', ones(size(phase)));
p.addParameter('incident', []);
p.addParameter('z', 0.0);
p.addParameter('padding', 100);
p.addParameter('methoddata', []);
p.addParameter('focallength', 1000);  % [lambda]
p.addParameter('axis', 'z');
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

% Allow the user to pass in a single complex amplitude or
% separate phase and amplitude matrices
if isreal(phase)

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
  assert(all(size(incident) == size(phase)), ...
    'Incident size must match phase size');
  assert(all(size(amplitude) == size(phase)), ...
    'Amplitude size must match phase size');

  % Check phase range
  if abs(1 - max(phase(:)) - min(phase(:))) < eps(1)
    warning('Phase range should be 2*pi');
  end

  % Generate combined pattern
  U = amplitude .* exp(1i*phase) .* incident;

else

  % The input is a complex amplitude
  U = phase;

end

switch p.Results.method
  case 'fft'
    varargout{1} = fft_method(U, p);
  case 'ott'
    [varargout{1:nargout}] = ott_method(U, p);
  case 'rs'
    [varargout{1:nargout}] = rs_method(U, p);
  case 'rslens'
    wavelength_per_pixel = 20;
    Uatlens = otslm.tools.visualise(U, ...
        'z', p.Results.focallength, 'method', 'rs');
    lensphase = otslm.simple.spherical(p.Results.focallength./wavelength_per_pixel, 'background', NaN);
    Uafterlens = Uatlens .* exp(1i*2*pi*lensphase);
    varargout{1} = otslm.tools.visualise(Uafterlens, ...
        'z', p.Results.z, 'method', 'rs');
  otherwise
    error('Unknown method');
end

end

function output = fft_method(U, p)
% z should be dimensionless, multiplied by a factor of 2pi/lambda

  axis = p.Results.axis;
  if ~strcmpi(axis, 'z')
    error('Only z-axis supported for now with fft');
  end

  z = p.Results.z;
  padding = p.Results.padding;

  % Apply padding to the image
  img = zeros(size(U)+2*[padding, padding]);
  img(padding+(1:size(U, 1)), padding+(1:size(U, 2))) = U;
  U = img;


  if strcmpi(p.Results.type, 'farfield')

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
    output = ifft2(fftshift(U));

  end
end

function [output, beam] = ott_method(U, p)

  axis = p.Results.axis;

  z = p.Results.z;
  beam = p.Results.methoddata;

  % TODO: We should choose this based on the output range
  % TODO: We should warn when Nmax gets much larger, memory/time
  Nmax = 20;

  % TODO: Set the output range to other values

  % TODO: Set the NA to other values
  NA = 1.02;

  % TODO: Lower resolution for output image

  % Calculate the beam shape coefficients of focussed beam
  polarisation = [ 1, 1i ];
  nMedium = 1.33;

  if isempty(beam)
    beam = ott.BscPmParaxial(NA, U, 'index_medium', nMedium, ...
        'polarisation', polarisation, 'Nmax', Nmax);
  end

  xrange = linspace(-3, 3, round(size(U, 2)/5))/nMedium;
  yrange = linspace(-3, 3, round(size(U, 1)/5))/nMedium;

  switch axis
    case 'x'
      [X1,Y1,Z1]=meshgrid(z, xrange, yrange);
    case 'y'
      [X1,Y1,Z1]=meshgrid(xrange, z, yrange);
    case 'z'
      [X1,Y1,Z1]=meshgrid(xrange, yrange, z);
    otherwise
      error('Unknown axis direction specified');
  end

  % Calculate the E field
  E = beam.emFieldXyz([X1(:),Y1(:),Z1(:)].');

  % Add the irradiance to the output
  output = sum(abs(E).^2, 1);

  % Add the z-phase to the output (is this a good idea?)
%   output = output .* exp(1i*angle(E(3, :)));

  % Turn the output back into an image
  output = reshape(output, [round(size(U, 1)/5), round(size(U, 2)/5)]);

end

function [output] = rs_method(U, p)

  scale = 1;                % Number of pixels in output
  uscale = 1;               % Upscaling of input input image
  pixelsize = [20, 20];     % Pixel size in units of wavelength

  % Repeat elements for multi-sampling
  U = repelem(U, uscale, uscale);

  output = otslm.tools.vis_rsmethod(U, pixelsize, p.Results.z, scale*uscale);

end

