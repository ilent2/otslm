function lt = smichelson(slm, cam, varargin)
% SMICHELSON uses images from a sloped Michelson interferometer
%
% Calculate the SLM lookup table using interference fringes on a
% sloped Michelson interferometer setup.  Either the SLM or reference
% beam mirror must be sloped with respect to the illumination causing
% interference fringes in the output.  By varying the phase on the
% device, the fringes can be made to move.  This can be done on
% half the device allowing the other half to be used as a reference.
%
% lt = smichelson(slm, cam, ...) calibrate using the smichelson method.
%
% Optional named parameters:
%     slice_index     idx     slice to use for method.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Parse method arguments
p = inputParser;
p.addParameter('slice_index', round(0.1*cam.roisize(2)));
p.parse(varargin{:});

% Generate pattern we will use
% Only mask half the device so we have a reference
mask = otslm.simple.step(slm.size, 'value', [false, true], 'angle_deg', 90);

% Generate full value table
valueTable = slm.linearValueRange('structured', true);

% The slice index to use
sidx = p.Results.slice_index;

% Measure phase of each value
phase = zeros(size(valueTable, 2), 1);
for ii = 1:size(valueTable, 2)

  % Generate raw pattern
  ipattern = ones(slm.size);
  ipattern(mask) = ii;

  % Display on slm and acquire image
  slm.showIndexed(ipattern);
  im = cam.viewTarget();

  % Extract two slices for reference and offset
  csliceref = sum(im(1:round(end/2), :), 1);
  cslicephs = sum(im(round(end/2)+1:end, :), 1);

  % Calculate frequencies of two slices
  fftref = fft(csliceref);
  fftphs = fft(cslicephs);

  % Extract phase from reference
  phase(ii) = angle(fftphs(sidx)) - angle(fftref(sidx));

  % Display a plot to show the slice we are using
  if ii == 1
    hf = figure();
    h = axes(hf);
    plot(h, abs(fftref));
    title('Frequency spectrum for sloped michelson method');
    hold(h, 'on');
    plot(h, abs(fftphs));
    V = axis(h);
    line([sidx sidx], V(3:4));
    hold(h, 'off');
    legend(h, {'reference', 'sample', 'frequency'});
  end
end

% Unwrap and normalize phase
phase = unwrap(-phase);
phase = phase - min(phase);

% Wrap in a lookup table structure
lt = otslm.utils.LookupTable(phase, valueTable);

