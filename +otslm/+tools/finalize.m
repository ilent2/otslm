function pattern = finalize(pattern, varargin)
% Finalize a pattern, applying a color map and taking the modulo.
%
% Usage
%   pattern = finalize(input, ...) finalizes the pattern.
%   For dmd type devices, the input is assumed to be the amplitude.
%   For slm type devices, the input is assumed to be the phase.
%
%   pattern = finalize(phase, 'amplitude', amplitude', ...) attempts
%   to generate a pattern encoding both the phase and amplitude.
%
% Parameters
%   - pattern (numeric) -- phase pattern to be finalized
%
% Optional named parameters
%   - 'modulo' (numeric|enum) -- Applies modulo to the pattern.
%     Modulo should either be a scalar or 'none' for no modulo.
%     (default: 1.0 for slm type devices and 'none' for dmd type devices).
%
%   - 'colormap' -- Colormap to apply to pattern.  For a list of
%     valid values, see :func:`colormap`.
%     (default: 'pmpi' for slm and 'gray' for dmd type devices).
%
%   - 'rpack' (enum) -- rotation packing of the pixels.
%    - 'none'  -- No additional steps required (default slm)
%    - '45deg' -- Device is rotated 45 degrees (aspect 1:2, default dmd)
%
%   - 'device' (enum) -- Specifies the type of device, changes the
%     default value for most arguments.  If all arguments are provided,
%     this argument has no impact.
%    - 'dmd' -- Digital micro mirror (amplitude) device
%    - 'slm' -- Spatial light modulator (phase) device
%
%   - 'encodemethod' method Method to use when encoding phase/amplitude
%    - 'checker'   -- (default) use checkerboard pattern and acos
%      correction (phase)
%    - 'grating'   -- Use linear grating and sinc correction (phase)
%    - 'magnitude' -- Use grating magnitude modulation (phase)
%
%   - 'amplitude' pattern Amplitude pattern to generate output for

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('modulo', []);
p.addParameter('device', 'slm');
p.addParameter('colormap', []);
p.addParameter('rpack', []);
p.addParameter('amplitude', []);
p.addParameter('encodemethod', 'checker');
p.parse(varargin{:});

% Set default colour map
cmap = p.Results.colormap;
if isempty(cmap)
  if strcmpi(p.Results.device, 'slm')
    cmap = 'pmpi';
  elseif strcmpi(p.Results.device, 'dmd')
    cmap = 'gray';
  else
    error('Unknown device');
  end
end

% Set default rpack
rpack = p.Results.rpack;
if isempty(rpack)
  if strcmpi(p.Results.device, 'slm')
    rpack = 'none';
  elseif strcmpi(p.Results.device, 'dmd')
    rpack = '45deg';
  else
    error('Unknown device');
  end
end

% Handle default modulo value for pattern
modv = p.Results.modulo;
if isempty(modv)
  if strcmpi(p.Results.device, 'slm')
    modv = 1.0;
  elseif strcmpi(p.Results.device, 'dmd')
    modv = 'none';
  else
    error('Unknown device');
  end
end

if ~isempty(p.Results.amplitude)
  
  % Handle omitted phase pattern
  if isempty(pattern)
    pattern = zeros(size(p.Results.amplitude));
  end

  if strcmpi(p.Results.device, 'slm')

    switch p.Results.encodemethod
      case 'checker'

        % Use a checkerboard background
        background = otslm.simple.checkerboard(size(pattern), ...
            'value', [-1, 1]);
          
        % Normalize the amplitude to a controlable range (if outside)
        amplitude = p.Results.amplitude;
        if max(abs(amplitude(:))) > 1.0
          warning('Amplitude > 1.0, normalizing to range 0 to 1');
          amplitude = amplitude ./ max(abs(amplitude(:)));
        end

        % This ratio depends on the background level
        mixratio = 2/pi*acos(abs(amplitude));

        % Add the amplitude and mix with the background
        pattern = pattern + angle(amplitude)/(2*pi)+0.5;
        pattern = pattern + mixratio.*angle(background)/(2*pi)+0.5;

      case 'grating'
        error('Not yet implemented');
      case 'magnitude'
        error('Not yet implemented');
      otherwise
        error('Encode method not recognized for phase pattern');
    end

  elseif strcmpi(p.Results.device, 'dmd')

    % First finalize the phase pattern
    pattern = otslm.tools.finalize(pattern, ...
        'modulo', p.Results.modulo, 'device', 'slm', ...
        'colormap', 'pmpi', 'rpack', 'none');
    modv = 'none';

    % Generate the amplitude pattern
    phase_amplitude = cos(pattern);
    amplitude = p.Results.amplitude .* phase_amplitude;
    pattern = 0.5*amplitude ./ max(abs(amplitude(:))) + 0.5;

  else
    error('Unknown device');
  end

end

% Apply modulo to pattern
if ischar(modv) && strcmpi(modv, 'none')
  % Nothing to do
elseif ~ischar(modv)
  pattern = mod(pattern, modv);
else
  error('Unknown modulo argument value');
end

% Apply colour map
pattern = otslm.tools.colormap(pattern, cmap);

% Apply rotation to pattern
switch rpack
  case 'none'
    % Nothing to do
  case '45deg'

    sz = size(pattern);
    npattern = zeros(ceil(sz(2)/2) + sz(1) - 1, ...
        ceil((sz(2)+1)/2) + sz(1) - 1);

    [ox, oy] = meshgrid(1:sz(2), 1:sz(1));
    nx = ceil((ox+1)/2) + oy - 1;
    ny = ceil(ox/2) + (sz(1) - 1) - (oy - 1);
    ind = sub2ind(size(npattern), ny, nx);

    npattern(ind) = pattern;

    pattern = npattern;

  otherwise
    error('Unknown option for rpack');
end

