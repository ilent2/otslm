function varargout = visualise(phase, varargin)
% VISUALISE generates far-field plane images of the phase pattern
%
% [output, ...] = visualise(phase, ...) visualise the phase plane.
% Some methods output additional parameters, such as the ott-toolbox beam.
%
% [output, ...] = visualise(complex_amplitude, ...) visualise the
% field with complex amplitude.
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
%         'fft3'        Use 3-D Fourier transform, if original image
%             is 2-D, converts to volume and takes Fourier transform.
%             If input is 3-D, directly applies 3-D Fourier transform.
%         'ott'         Use optical tweezers toolbox
%         'rs'          Rayleigh-Sommerfeld diffraction formula
%         'rslens'      Use rs to propagate to a lens, apply the lens
%             phase pattern and propagate some distance from the lens.
%
%   'type'      type      Type of transformation: 'nearfield' or 'farfield'
%
%   'amplitude' image     Specifies the amplitude pattern
%   'incident'  image     Specifies the incident illumination
%       Default illumination is uniform intensity and phase.
%   'z'         z         z-position of output plane.  For fft/ott this
%       is an offset from the focal plane.  For rs/rslens, this is the
%       distance along the beam axis.
%   'padding'   p         Add padding to the outside of the image.
%   'trim_padding', bool  Trim padding before returning result (default: 0)
%   NA          num       Numerical aparture of the lens (default: 0.1)
%   resample    num       Number of samples per each pixel
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('method', 'fft');
p.addParameter('type', 'farfield');
p.addParameter('amplitude', []);
p.addParameter('incident', []);
p.addParameter('z', 0.0);
p.addParameter('padding', 100);
p.addParameter('trim_padding', false);
p.addParameter('methoddata', []);
p.addParameter('NA', 0.1);
p.addParameter('resample', []);
p.addParameter('axis', 'z');
p.parse(varargin{:});

% Create a beam object from the inputs
U = otslm.tools.make_beam(phase, ...
    'incident', p.Results.incident, ...
    'amplitude', p.Results.amplitude);

% Resample the image at a higher resolution
if ~isempty(p.Results.resample)
  
  assert(~any(isnan(U(:))), 'Beam must be non-nan');

  sampling = p.Results.resample;

  sz = size(U);

  % Generate original grid
  x0 = 1:sz(2);
  y0 = 1:sz(1);
  [xx0, yy0] = meshgrid(x0, y0);

  % Generate re-sampled grid
  x1 = (1:1/sampling:sz(2)) + rem((sz(2)-1), 1/sampling)/2;
  y1 = (1:1/sampling:sz(1)) + rem((sz(1)-1), 1/sampling)/2;
  [xx1, yy1] = meshgrid(x1, y1);

  % Resample
  U = interp2(xx0, yy0, U, xx1, yy1);
  
  assert(~any(isnan(U(:))), 'Interpolation failed with nans');
end

switch p.Results.method
  case 'fft'
    if strcmpi(p.Results.type, 'farfield')
      [varargout{1:nargout}] = otslm.tools.prop.FftForward.simple(U, ...
        'trim_padding', p.Results.trim_padding, 'padding', p.Results.padding, ...
        'NA', p.Results.NA, 'axial_offset', p.Results.z);
    elseif strcmpi(p.Results.type, 'nearfield')
      [varargout{1:nargout}] = otslm.tools.prop.FftInverse.simple(U, ...
        'trim_padding', p.Results.trim_padding, 'padding', p.Results.padding, ...
        'NA', p.Results.NA, 'axial_offset', p.Results.z);
    else
      error(['Invalid visualisation type: ', p.Results.type]);
    end
    
  case 'fft3'
    if strcmpi(p.Results.type, 'farfield')
      if ismatrix(U)
        [varargout{1:nargout}] = otslm.tools.prop.FftEwaldForward.simple(U, ...
          'trim_padding', p.Results.trim_padding, 'padding', p.Results.padding, ...
          'NA', p.Results.NA);
      else
        [varargout{1:nargout}] = otslm.tools.prop.Fft3Forward.simple(U, ...
          'trim_padding', p.Results.trim_padding, 'padding', p.Results.padding);
      end
    elseif strcmpi(p.Results.type, 'nearfield-surface')
      [varargout{1:nargout}] = otslm.tools.prop.FftEwaldInverse.simple(U, ...
        'trim_padding', p.Results.trim_padding, 'padding', p.Results.padding, ...
        'NA', p.Results.NA);
    elseif strcmpi(p.Results.type, 'nearfield-volume')
      [varargout{1:nargout}] = otslm.tools.prop.Fft3Inverse.simple(U, ...
        'trim_padding', p.Results.trim_padding, 'padding', p.Results.padding);
    else
      error(['Invalid visualisation type: ', p.Results.type]);
    end
    
  case 'ott'
    if strcmpi(p.Results.type, 'farfield')
      [varargout{1:nargout}] = otslm.tools.prop.Ott2Forward.simple(U, ...
        'beam_data', p.Results.methoddata, 'NA', p.Results.NA, 'index_medium', 1.0, ...
        'offset', p.Results.z, 'axis', p.Results.axis, 'field', 'irradiance');
    else
      error(['Invalid visualisation type: ', p.Results.type]);
    end
    
  case 'rs'
    if strcmpi(p.Results.type, 'farfield')
      [varargout{1:nargout}] = otslm.tools.prop.RsForward.simple(U, p.Results.z);
    else
      error(['Invalid visualisation type: ', p.Results.type]);
    end
    
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

function output = fft3_method(U, p)

  % Handle multiple padding arguments
  if isempty(p.Results.padding)
    padding = [0, 0, 0];
  elseif numel(p.Results.padding) == 1
    padding = [1, 1, 1].*p.Results.padding;
  elseif numel(p.Results.padding) == 2
    padding = [p.Results.padding(1), ...
        p.Results.padding(1), p.Results.padding(2)];
  elseif numel(p.Results.padding) == 3
    padding = p.Results.padding;
  else
    error('Padding must be 1, 2, or 3 elements');
  end

  % Ensure the input is a volume, if not, convert it
  if size(U, 3) == 1
    diameter = sqrt(size(U, 1).^2 + size(U, 2).^2);
    focal_length = diameter./tan(asin(p.Results.NA)).*2;
    U = otslm.tools.hologram2volume(U, ...
        'focal_length', focal_length, ...
        'padding', padding(3));
  elseif padding(3) ~= 0
    U = padarray(U, [0, 0, padding(3)], 0, 'both');
  end

  U = padarray(U, [padding(1:2), 0], 0, 'both');

  if strcmpi(p.Results.type, 'farfield')
    output = fftshift(fftn(U))./numel(U);
  elseif strcmpi(p.Results.type, 'nearfield');
    output = ifftn(fftshift(U));
  else
    error('OTSLM:TOOLS:VISUALISE:type_error', ...
        'Unknown conversion type, must be farfield or nearfield');
  end

  % Remove padding if requested
  if p.Results.trim_padding

    % Hmm, we could also resample at the original resolution

    szOutput = size(output);
    opadding = floor(szOutput/4);

    output = output(opadding(1)+1:end-opadding(1), ...
        opadding(2)+1:end-opadding(2), ...
        opadding(3)+1:end-opadding(3));
  end

end



