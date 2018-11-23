classdef LookupTable
% LOOKUPTABLE represents the phase and pixel values of a lookup table
%
% Lookup tables can be used by Showable devices and tools.finalize.
%
% Methods:
%   load        load a human readable lookup table from a file
%   save        save a human readable lookup table to a file
%
% Properties:
%   phase       phase values in lookup table [Nx1 matrix]
%   value       pixel values in lookup table [NxM matrix]
%   range       range of the lookup table (for phase based tables)
%
% See also otslm.tools.finalize and otslm.utils.Showable
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties
    phase       % phase values in lookup table [Nx1 matrix]
    value       % pixel values in lookup table [NxM matrix]
    range       % range of the lookup table (for phase based tables)
  end

  methods (Static)
    function lt = load(filename, varargin)
      % Load a lookup table from a file
      %
      % This is useful if you want to use the lookup table in another
      % program.  Otherwise, the recommended way to save a lookup
      % table is by using the matlab save function.
      %
      % lt = LookupTable.load(filename, ...) loads the lookup table.
      %
      % Optional named arguments:
      %     'channels'    channels    Array of columns numbers in input file
      %       0 correspond to 0 in output.  Negative values correspond to
      %       columns in reverse order.
      %
      %   'phase'       column      Column of input file taken as phase
      %       value.  If omitted, i.e. [], assumes 0 to 2*pi linear
      %       phase range.
      %
      %   'oformat'     format      Output format string (default: uint8)
      %   'format'      format      Input format handle (default @uint8)
      %   'mask'        mask        Mask for input format (default: none)
      %   'morder'      order       Array for order of bits in mask
      %       length should be 8, (0: zero bit, 1:8 mask bit, other: one bit).
      %       1:8 is normal bit order, 8:-1:1 is reverse order.
      %   'delim'       delim       Deliminator in input file
      %   'nheaderlines' num        Number of header lines in file
      %
      % The number of channels in the output is determined by the length
      % of the channels array.  Each element in the channels array determines
      % which column of the input file (starting at 1) is used to generate
      % the channel data.  A value of 0 means that this channel is empty.
      %
      % The format argument specifies the input data type for each column.
      % Data is read, cast to this type, and then the mask is applied.
      % The output value is then calculated as a uint8 from the bits
      % that were masked using the morder argument.
      %
      % Examples:
      %
      %   Load a 16-bit lookup table with values assigned to the first two
      %   channels.  The input file has two columns, we use the second.
      %     lookup_table = 'LookupTable.txt';
      %     colormap = otslm.utils.LookupTable.load(lookup_table, ...
      %       'channels', [2, 2, 0], 'phase', [], 'format', @uint16, ...
      %       'mask', [hex2dec('00ff'), hex2dec('ff00')]);

      % TODO: Different morder for each channel

      p = inputParser;
      p.addParameter('channels', [ -1, 0, 0 ]);
      p.addParameter('phase', []);
      p.addParameter('oformat', 'uint8');
      p.addParameter('format', @uint8);
      p.addParameter('mask', []);
      p.addParameter('morder', 1:8);
      p.addParameter('delim', '\t');
      p.addParameter('nheaderlines', 1);
      p.parse(varargin{:});

      % Check file exists
      if ~isfile(filename)
        error(['File does not exist: ' filename]);
      end

      % Read data file
      data_struct = importdata(filename, p.Results.delim, ...
          p.Results.nheaderlines);

      % Check file was read
      if isempty(data_struct)
        error('File exists but unable to import data from file');
      end

      % Get data from structure
      data = data_struct.data;

			% Allocate space for lookup table
			values = zeros(size(data, 1), length(p.Results.channels), ...
					p.Results.oformat);

			% Generate each channel from the data
			for ii = 1:length(p.Results.channels)

				chidx = p.Results.channels(ii);

				% Select the channel
				if chidx < 0
					ch = data(:, end-chidx+1);
				elseif chidx == 0
					% Nothing to do
					continue
				else
					ch = data(:, chidx);
				end

				% Convert column to appropriate data type
				ch = p.Results.format(ch);

				% Apply mask to column
				if ~isempty(p.Results.mask)

					% Sort bits in input into ascending order
					usch = ch;
					ch = ch*0;
					numBits = 0;
					for jj = 1:64
						if bitand(p.Results.mask(ii), 2^(jj-1))
							ch = bitor(ch, cast(logical(bitand(...
                  usch, 2^(jj-1)))*2^(numBits), 'like', usch));
							numBits = numBits + 1;
						end
					end

				else
					numBits = 8;
				end

				% Select the bits required for the output column
				for jj = 1:length(p.Results.morder)
					if p.Results.morder(jj) <= 0
						% Add an off bit at this location
						% Nothing to do
					elseif p.Results.morder(jj) > numBits
						% Add an on bit at this location
						values(:, ii) = bitor(values(:, ii), ...
                cast(2^(jj-1), p.Results.oformat));
					else
						% Add the bit from the lookup table to this location
						values(:, ii) = bitor(values(:, ii), ...
								cast(logical(bitand(ch, ...
                2^(p.Results.morder(jj)-1)))*2^(jj-1), p.Results.oformat));
					end
				end
			end

			% Read phase from file if requested
			if ~isempty(p.Results.phase)
				phase = data(:, p.Results.phase);
      else
        phase = linspace(0, 2*pi, size(values, 1)).';
			end

      % Package into a lookup table
      lt = otslm.utils.LookupTable(phase, values, 'range', 2*pi);
    end
  end

  methods
    function lt = LookupTable(phase, value, varargin)
      % Construct a new LookupTable instance
      %
      % lt = LookupTable(phase, value, ...)
      %
      % Optional named arguments:
      %   range    num    The range of the look up table.  This will
      %      typically be either 1 or 2*pi depending on if the lookup
      %      table is normalized or un-normalized.  The actual ranges
      %      of phase values may be less or greater than this range.
      
      p = inputParser;
      p.addParameter('range', 2*pi);

      assert(size(phase, 1) == numel(phase), 'Phase must be column vector');
      assert(size(phase, 1) == size(value, 1), ...
          'Number of rows in phase and value table must be equal');

      lt.phase = phase;
      lt.value = value;
      lt.range = p.Results.range;
    end

    function save(lt, filename, varargin)
      % Save the lookup table to a human readable file
      %
      % This is useful if you want to use the lookup table in another
      % program.  Otherwise, the recommended way to save a lookup
      % table is by using the matlab save function.
      %
      % lt.save(filename, ...) saves the lookup table to file.
      %
      % Optional named arguments:
      %   header    str     header lines describing file contents.
      %       Default is a message about when the file was generated.
      %   cols      [cols]  specifies which columns of values will be written
      %   format    str     type type of lookup table to write.
      %       All formats write the phase in the first column.
      %       This argument controls what is placed in additional columns.
      %       Currently supported types are:
      %         8bit    write a single column of 8 bit integers
      %         16bit   write a single column of 16 bit integers
      %         none    don't write any additional column
      %         multi   write one column for each value channel

      p = inputParser;
      p.addParameter('header', ['SLM lookup table generated at ' datetime()]);
      p.addParameter('format', 'multi');
      p.addParameter('cols', []);
      p.parse(varargin{:});

      assert(ischar(p.Results.header), 'Header must be a character array');

      % Get column orders
      cols = p.Results.cols;
      if isempty(cols)
        cols = 1:size(lt.values, 2);
      end

      % Open file
      fp = fopen(filename, 'w');
      fprintf(fp, '%s\n', deblank(p.Results.header));

      % Handle different file formats
      switch p.Results.format
        case 'multi'
          cols = repmat('\t%f', [1, length(cols)]);
          fprintf(fp, ['%f' cols '\n'], [lt.phase, lt.values(:, cols)].');

        case '8bit'

          % Determine which column we want to write
          if isempty(p.Results.cols)
            mm = minmax(lt.values(:, cols).');
            idx = mm(:, 1) ~= mm(:, 2);
            assert(sum(idx) == 1 || size(lt.values, 2) == 1, ...
                'Unable to determine which column to output');
            if sum(idx) ~= 1
              idx = 1;
            end
          else
            idx = cols;
          end

          % TODO: Should we have additional checking on values?

          fprintf(fp, '%f%f\n', [lt.phase, lt.values(:, idx)].');

        case '16bit'

          if isempty(p.Results.cols)
            mm = minmax(lt.values(:, cols).');
            idx = mm(:, 1) ~= mm(:, 2);
            assert(sum(idx) == 2 || size(lt.values, 2) == 2, ...
                'Unable to determine which column to output');
            if sum(idx) ~= 2
              idx = [1, 2];
            end
            warning('otslm:utils:LookupTable:save:16bit_guess', ...
                'Assuming columns of lookup table may be unsafe');
          else
            idx = cols;
          end

          % TODO: Should we have additional checking on values?

          fprintf(fp, '%f%f\n', [lt.phase, ...
              lt.values(:, idx(1)) + lt.values(:, idx(2)).*2^8].');

        case 'none'
          fprintf(fp, '%f\n', lt.phase.');

        otherwise
          error('Unknown file format type specified');
      end

      fclose(fp);
    end

    function nlt = sorted(lt)
      % Returns a new lookup table sorted by phase
      %
      % nlt = lt.sorted()

      [sortedPhase, idx] = sort(lt.phase);
      sortedValue = lt.value(idx, :);

      nlt = LookupTable(sortedPhase, sortedValue);
    end

    function nlt = resample(lt, nphase)
      % Generates a new lookup table re-sampled at the specified phases
      %
      % nlt = lt.resample(nphase) returns a new lookup table re-sampled
      % at the specified phases.  Values assigned to new phases correspond
      % to the nearest values in the old table.

      nlt = interp1(lt.phase, double(lt.value), nphase, 'nearest');
      nlt = cast(nlt, 'like', lt.value);
    end

    function nlt = linearised(lt, numpts, varargin)
      % Generates a new lookup table with evenly spaced values
      %
      % nlt = lt.linearised(lt, numpts, ...) generates a resampled
      % lookup table with evenly spaced values.
      %
      % Optional named arguments
      %     range     [min, max]  range to re-sample. Default: minmax(phase).
      %     periodic  bool        specifies if the range is periodic, if
      %       so, the end points count as the same point.  Default false.

      p = inputParser;
      p.addParameter('range', minmax(lt.phase));
      p.addParameter('periodic', false);
      p.parse(varargin{:});

      if p.Results.periodic
        % TODO: What if values at other end are closer?
        range = linspace(p.Results.range(1), p.Results.range(2), numpts+1);
        nlt = lt.resample(range(1:end-1));
      else
        range = linspace(p.Results.range(1), p.Results.range(2), numpts);
        nlt = lt.resample(range);
      end
    end

    function nlt = valueMinimised(lt, valueRangeSz)
      % Arranges lookup table so phase values are ascending but
      % attempts to minimise change in linear index between steps.
      %
      % nlt = lt.valueMinimised(lt, valueRangeSz) requires information
      % about the size of each valueRange dimension (vector).
      %
      % See also otslm.utils.Showable.valueRangeSize()

      phase = lt.phase - min(lt.phase);

      % TODO: Allow user to specify start value
      % [~, idx] = min(abs(phase - max(phase)/2));
      % Start at the centre of the device minus range/2
      %[~, idx] = min(abs(phase - max(phase)/2 + p.Results.tablerange/2));
      [~, idx] = min(phase);

      % Reshape the phase array to make traversal easier
      if length(valueRangeSz) == 1
        phaseNd = phase;
      else
        phaseNd = reshape(phase, valueRangeSz);
      end

      % Shift phaseNd to zero
      phaseNd = phaseNd - phase(idx);

      sortedPhaseIdx = [idx];
      sortedPhase = [0.0];
      candidates = phaseNd > sortedPhase(end)
      [lastCoord{1:length(valueRangeSz)}] = ind2sub(size(phaseNd), idx);
      while any(candidates)

        % Calculate distance^2 of all candidates (periodic boundaries)
        indices = find(candidates);
        [coords{1:length(valueRangeSz)}] = ind2sub(size(phaseNd), indices);
        distances = zeros(size(indices));
        for ii = 1:length(coords)

          % Calculate relative coordinates
          relCoords = coords{ii} - lastCoord{ii};

          % Apply periodic condition
          relCoords(relCoords > valueRangeSz(ii)/2) = ...
              relCoords(relCoords > valueRangeSz(ii)/2) - valueRangeSz(ii);
          relCoords(relCoords < -valueRangeSz(ii)/2) = ...
              relCoords(relCoords < -valueRangeSz(ii)/2) + valueRangeSz(ii);

          % Calculate distance^2
          distances = distances + relCoords.^2;
        end

        % Bias distance for nearby phase
        % TODO: Allow user to specify phaseChangeScale
        phaseChange = phaseNd(candidates) - sortedPhase(end);
        phaseChangeScale = 1.5*numel(phase)/max(phase(:));
        distances = distances + (phaseChangeScale*phaseChange).^2;

        % Find and store nearest candidate
        [~, canidx] = min(distances);
        idx = indices(canidx);
        [lastCoord{1:length(valueRangeSz)}] = ind2sub(size(phaseNd), idx);
        sortedPhaseIdx(end+1) = idx;
        sortedPhase(end+1) = phaseNd(idx);

        % Calculate new candidates
        candidates = phaseNd > sortedPhase(end);
      end

      % Retrieve corresponding values
      sortedValue = lt.value(sortedPhaseIdx, :);

      nlt = LookupTable(sortedPhase, sortedValue);
    end
  end
end
