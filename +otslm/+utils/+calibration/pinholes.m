function lt = pinholes(slm, cam, varargin)
% PINHOLES generates virtual pinholes with different phase
%
% Similar to step but looks at interference of two regions on
% different parts of the device allowing per-pixel or per-region
% calibration.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Parse method arguments
p = inputParser;
p.parse(varargin{:});

% Design a pattern that minimises intensity in target
% This adds noise to the output, but can still produce reasonable results
% TODO: Allow the user to supply a base pattern or use checkerboard
% TODO: Average over multiple background patterns
% TODO: Optimisation to minimise power in zeroth order
basepattern = randi(slm.valueRangeNumel(), slm.size);

% Generate mask for pinhole regions
r = 10;
o = 20;
c1 = [ceil(slm.size(2)/2)-o, ceil(slm.size(1)/2)];
c2 = [ceil(slm.size(2)/2)+o, ceil(slm.size(1)/2)];
mask_pinhole1 = otslm.simple.aperture(slm.size, r, 'centre', c1);
mask_pinhole2 = otslm.simple.aperture(slm.size, r, 'centre', c2);

% Generate full value table
valueTable = slm.linearValueRange('structured', true);

% The slice index to use
sidx = 22;

% Measure phase of each value
phase = zeros(size(valueTable, 2), 1);
for ii = 1:size(valueTable, 2)

  % Generate raw pattern
  ipattern = basepattern;
  ipattern(mask_pinhole1) = 1;
  ipattern(mask_pinhole2) = ii;

  % Display on slm and acquire image
  slm.showIndexed(ipattern);
  im = cam.viewTarget();

  % Extract the fringes from the image
  cslice = sum(im, 1);
  fftcslice = fft(cslice - 0.5.*max(cslice(:))); % zeroth order reduced
  phase(ii) = angle(fftcslice(sidx));
  
  % Display a plot to show the slice we are using
  if ii == 1
    hf = figure();
    h = axes(hf);
    plot(h, abs(fftcslice));
    title('Frequency spectrum for pinhole method');
    hold(h, 'on');
    plot(h, sidx, abs(fftcslice(sidx)), 'ro');
    hold(h, 'off');
    legend(h, {'FFT', 'Phase'});
  end
end

% Unwrap and normalize phase
phase = unwrap(-phase);
phase = phase - min(phase);

% Wrap output in lookup table
lt = otslm.utils.LookupTable(phase, valueTable);

