function lookupTable = calibrate(slm, cam, varargin)
% CALIBRATE method to calibrate phase-only SLM
%
% lookuptable = calibrate(slm, cam, ...) attempts to calibrate the
% showable device (slm) imaged using the viewable device (cam).
% The default method assumes the camera is in the Fourier plane of
% the SLM.  The generated lookup table is a cell array with two cells,
% the phase values [0, 1] and a table of corresponding device values.
%
% lookuptable = calibrate(slm, cam, 'tableres', res, ...) as above
% but produces a single column lookup table with res evenly spaced
% elements in the phase range.
%
% Optional named parameters:
%
%   'method'      method    Method to use for calibration.
%   'methodargs'  {args}    Method specific arguments.
%       See bellow for methods and method arguments.
%
%   'tablerange'  range     Range of values in lookup table.
%       'full'        Assign a phase value to every pixel value combination
%       number        A range to find values over (default: 2*pi)
%
%   'rangemethod' method    Method to use for sorting values.
%       'minvalue'    Minimise the difference in value, for 1-D devices
%          this will typically be device values in order.  For N-D
%          devices assumes periodic values and tries to minimise distance.
%       'sort'        Sort all values irrespective of value
%
%   'tableres'    res       Table resolution.  Defaults to lowest
%       resolution needed for range.  Runs 1-D nearest value
%       interpolation to generate a linear lookup table.
%
% Supported methods:
%
%   'checker'         Minimise the zero-th order by changing the phase
%       of the values in a checkerboard.
%
%   'michaelson'      Michaelson interferometer image of SLM surface.
%       Change in intensity of image determines phase change.
%
%   'smichaelson'     Sloped Michaelson interferometer with fringes.
%       Changes half the SLM phase which shifts the fringes on half
%       of the device.
%
%   'step'            Applies a step function and looks at the minima.
%   'pinholes'        Applies pinholes with different phase.
%   'linear'          Attempt to optimise diffraction from linear grating.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('method', 'checker');
p.addParameter('methodargs', {});
p.addParameter('tablerange', 2*pi);
p.addParameter('tableres', []);
p.addParameter('rangemethod', 'minvalue');
p.parse(varargin{:});

switch p.Results.method
  case 'checker'
    lookupTable = method_checker(slm, cam, p.Results.methodargs{:});
  case 'michaelson'
    lookupTable = method_michaelson(p.Results.tablerange, ...
        p.Results.methodargs);
  case 'smichaelson'
    lookupTable = method_smichaelson(p.Results.tablerange, ...
        p.Results.methodargs);
  case 'step'
    lookupTable = method_step(p.Results.tablerange, p.Results.methodargs);
  case 'pinholes'
    lookupTable = method_pinholes(p.Results.tablerange, p.Results.methodargs);
  case 'linear'
    lookupTable = method_linear(p.Results.tablerange, p.Results.methodargs);
  otherwise
    error('Unknown method paremter given');
end

% Convert from full range to desired range
if ~ischar(p.Results.tablerange)

  minphase = min(lookupTable{1});
  maxphase = max(lookupTable{1});

  if maxphase - minphase < p.Results.tablerange
    warning('Device range smaller than requested range');
  end

  phase = lookupTable{1} - minphase;
  value = lookupTable{2};

  switch p.Results.rangemethod
    case 'sort'

      % Discard values outside range
      value = value(phase <= p.Results.tablerange);
      phase = phase(phase <= p.Results.tablerange);

      % Sort the lookupTable
      [sortedPhase, idx] = sort(phase);
      sortedValue = value(:, idx);

    case 'minvalue'

      % Start at the centre of the device minus range/2
      % TODO: Allow user to specify start value
      [~, idx] = min(abs(phase - max(phase)/2 + p.Results.tablerange/2));

      % Reshape the phase array to make traversal easier
      valueRangeSz = slm.valueRangeSize();
      if length(valueRangeSz) == 1
        phaseNd = phase;
      else
        phaseNd = reshape(phase, valueRangeSz);
      end

      % Shift phaseNd to zero
      phaseNd = phaseNd - phase(idx);

      sortedPhaseIdx = [idx];
      sortedPhase = [0.0];
      candidates = phaseNd > sortedPhase(end) & phaseNd < p.Results.tablerange;
      lastCoord = ind2sub(size(phaseNd), idx);
      while any(candidates)

        % Calculate distance^2 of all candidates (periodic boundaries)
        indices = find(candidates);
        [coords{1:length(slm.valueRange)}] = ind2sub(size(phaseNd), indices);
        distances = zeros(size(indices));
        for ii = 1:length(coords)

          % Calculate relative coordinates
          relCoords = coords{ii} - lastCoord;

          % Apply periodic condition
          relCoords(relCoords > valueRangeSz(ii)/2) = ...
              relCoords(relCoords > valueRangeSz(ii)/2) - valueRangeSz(ii);
          relCoords(relCoords < -valueRangeSz(ii)/2) = ...
              relCoords(relCoords > valueRangeSz(ii)/2) + valueRangeSz(ii);

          % Calculate distance^2
          distances = distances + relCoords.^2;
        end

        % Find and store nearest candidate
        [~, canidx] = min(distances);
        idx = indices(canidx);
        lastCoord = ind2sub(size(phaseNd), idx);
        sortedPhaseIdx(end+1) = idx;
        sortedPhase(end+1) = phaseNd(idx);

        % Calculate new candidates
        candidates = phaseNd > sortedPhase(end) & phaseNd < p.Results.tablerange;
      end

      % Retrieve corresponding values
      sortedValue = value(:, sortedPhaseIdx);

    otherwise
      error('Unknown rangemethod parameter value');
  end

  % Pack result
  lookupTable = { sortedPhase, sortedValue };

elseif strcmpi(p.Results.tablerange, 'full')
  % Nothing to do
else
  error('Unknown table range parameter value');
end

% Generate the linearised lookup table
if ~isempty(p.Results.tableres)

  range = linspace(0, p.Results.tablerange, p.Results.tableres);
  phase = lookupTable{1};
  value = lookupTable{2};

  % Generate the lookup table, being careful to preserve class
  oldclass = class(value);
  lookupTable = interp1(phase, double(value), range, 'nearest');
  lookupTable = cast(lookupTable, oldclass);

end

end

function lookupTable = method_checker(slm, cam, varargin)
% Measures the intensity of the zero order for different checkerboard
% patterns applied to the device.

  % Parse method arguments
  p = inputParser;
  p.parse(varargin{:});

  % For this method we do the same procedure twice to classify points
  % in the range |phase| = 0 <= pi, then again for |phase-pi/2| = 0 <= pi.
  % The actual phase is then
  %
  %   0   pi/2
  %   <     <   0 - pi/2
  %   >     <   pi/2 -> pi
  %   >     >   pi -> 3pi/2
  %   <     >   3pi/2 -> 2pi

  % Generate the checkerboard
  mask = otslm.simple.checkerboard(slm.size, 'value', [false, true]);

  % Generate full value table
  valueTable = slm.linearValueRange('structured', true);

  % Rank everything in region 1
  idx1 = 1;
  value1 = valueTable(:, idx1);
  phase1 = zeros([size(valueTable, 2), 1]);
  for ii = 1:size(valueTable, 2)

    % Generate pattern
    rawpattern = generate_raw_pattern(slm, mask, ...
        value1, valueTable(:, ii));

    % Show pattern and get image
    slm.showRaw(rawpattern);
    im = cam.viewTarget();

    % Calculate intensity in target region
    phase1(ii) = sum(im(:));

  end
  phase1 = phase1 - min(phase1);

  % Choose a region 2 and rank everything in this region
  [~, idx2] = min(abs(phase1 - max(phase1)/2));
  value2 = valueTable(:, idx2);
  phase2 = zeros([size(valueTable, 2), 1]);
  for ii = 1:size(valueTable, 2)

    % Generate pattern
    rawpattern = generate_raw_pattern(slm, mask, ...
        value2, valueTable(:, ii));

    % Show pattern and get image
    slm.showRaw(rawpattern);
    im = cam.viewTarget();

    % Calculate intensity in target region
    phase2(ii) = sum(im(:));

  end
  phase2 = phase2 - min(phase2);

  % Determine which region points are in
  phase2small = phase2 - max(phase2)/2 < 0;
  
  % Convert from intensity to phase
  phase = sqrt(phase1./max(phase1));
  phase(~phase2small) = -phase(~phase2small);
  phase = unwrap(2*acos(phase));

  % Package into lookupTable
  lookupTable = {phase, valueTable};

end

function lookupTable = method_michaelson(slm, cam, varargin)

  % Parse method arguments
  p = inputParser;
  p.parse(varargin{:});

  % TODO: michaelson interferometer method
  error('Not yet implemented');

end

function lookupTable = method_smichaelson(slm, cam, varargin)

  % Parse method arguments
  p = inputParser;
  p.parse(varargin{:});

  % Generate pattern we will use
  % Only mask half the device so we have a reference
  mask = logical(otslm.simple.step(slm.size, 'value', [0, 1]));

  % Generate full value table
  valueTable = slm.linearValueRange('structured', true);

  % Measure phase of each value
  for ii = 1:size(valueTable, 1)

    % Generate raw pattern
    rawpattern = generate_raw_pattern(slm, pattern, ...
        valueTable(1, :), valueTable(ii, :));

    % Display on slm and acquire image
    slm.showRaw(rawpattern);
    im = cam.viewTarget();

    % TODO: Extract two slices for reference and offset

    % TODO: Extract phase from each region and calculate difference
    error('Not yet implemented');

  end

  % TODO: Package result

end

function lookupTable = method_linear(slm, cam, varargin)

  % Parse method arguments
  p = inputParser;
  p.parse(varargin{:});

  % TODO: Different optimisation methods (simulated annealing?)

  % Assume the valueTable is in sequential order (might not be)
  % and try to fit a line to it
  % TODO: Allow the user to pick an initial guess/range
  phase = linspace(0, 1, numsteps);

  % TODO: Generate linear grating with this phase mapping
  % TODO: Evaluate the initial guess and use as baseline

  error('Not yet implemented');

  % While not converged
  while not_converged

    % Randomly pick a point to shift

    % Check the shift

    % If the shift improved the result, keep it

  end

  % Package the result

end

function lookupTable = method_pinholes(slm, cam, varargin)

  % Parse method arguments
  p = inputParser;
  p.parse(varargin{:});

  % Design a pattern that minimises intensity in target
  basepattern = generate_random_pattern(slm);

  % Generate mask for pinhole regions
  r = 10;
  o = 20;
  c1 = [ceil(slm.size(2)/2)-o, ceil(slm.size(1)/2)];
  c2 = [ceil(slm.size(2)/2)+o, ceil(slm.size(1)/2)];
  mask_pinhole1 = otslm.simple.aperture(slm.size, r, 'centre', c1);
  mask_pinhole2 = otslm.simple.aperture(slm.size, r, 'centre', c2);

  % Generate full value table
  valueTable = slm.linearValueRange('structured', true);

  % Measure phase of each value
  for ii = 1:size(valueTable, 1)

    % Generate raw pattern
    rawpattern = basepattern;
    rawpattern = add_masked_region(slm, rawpattern, ...
        mask_pinhole1, valueTable(1, :));
    rawpattern = add_masked_region(slm, rawpattern, ...
        mask_pinhole2, valueTable(ii, :));

    % Display on slm and acquire image
    slm.showRaw(rawpattern);
    im = cam.viewTarget();

    % TODO: Extract the fringes from the image
    error('Not yet implemented');
  end

end

function lookupTable = method_step(slm, cam, varargin)

  % Parse method arguments
  p = inputParser;
  p.parse(varargin{:});

  % Generate pattern we will use
  pattern = logical(otslm.simple.step(slm.size, 'value', [0, 1]));

  % Generate full value table
  valueTable = slm.linearValueRange('structured', true);

  % Do full range test
  for ii = 2:size(valueTable, 1)

    % Generate raw pattern
    rawpattern = generate_raw_pattern(slm, pattern, ...
        valueTable(1, :), valueTable(ii, :));

    % Display on slm
    slm.showRaw(rawpattern);

    % Get image of target
    im = cam.viewTarget();

    % TODO: Extract the dark frindge from the image
    error('Not yet implemented');

  end

end

function rawpattern = generate_raw_pattern(slm, mask, base, value)
% Generate a raw image for the slm by masking the base and value
%
%   rawpattern(~mask) = base;
%   rawpattern(mask) = value;

  rawpattern = zeros([slm.size, length(value)]);
  for jj = 1:length(value)
    layer = repmat(base(jj), slm.size);
    layer(mask) = repmat(value(jj), size(layer(mask)));
    rawpattern(:, :, jj) = layer;
  end

end
