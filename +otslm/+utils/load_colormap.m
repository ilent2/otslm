function lookupTable = load_colormap(filename, varargin)
% LOAD_COLORMAP loads a colormap from file, colormaps can be used
% for SLM devices or in the tools.finalize colormap argument.
%
% lookupTable = load_colormap(filename, ...) loads the lookup table.
% The lookupTable is a cell array with { phase, values } if the
% 'phase' named argument is included, otherwise it is a matrix.
%
% Optional named arguments:
%
%   'channels'    channels    Array of columns numbers in input file
%       0 correspond to 0 in output.  Negative values correspond to
%       columns in reverse order.
%
%   'phase'       column      Column of input file taken as phase
%       value.  If omitted, i.e. [], assumes 0 to 2*pi linear phase range.
%
%   'oformat'     format      Output format string (default: uint8)
%   'format'      format      Input format function handle (default @uint8)
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
%     colormap = otslm.utils.load_colormap(lookup_table, ...
%       'channels', [2, 2, 0], 'phase', [], 'format', @uint16, ...
%       'mask', [hex2dec('00ff'), hex2dec('ff00')]);
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

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

% Read data file
data_struct = importdata(filename, p.Results.delim, p.Results.nheaderlines);
data = data_struct.data;

% Allocate space for lookup table
lookupTable = zeros(size(data, 1), length(p.Results.channels), ...
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
        ch = bitor(ch, cast(logical(bitand(usch, 2^(jj-1)))*2^(numBits), 'like', usch));
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
      lookupTable(:, ii) = bitor(lookupTable(:, ii), cast(2^(jj-1), p.Results.oformat));
    else
      % Add the bit from the lookup table to this location
      lookupTable(:, ii) = bitor(lookupTable(:, ii), ...
          cast(logical(bitand(ch, 2^(p.Results.morder(jj)-1)))*2^(jj-1), p.Results.oformat));
    end
  end
end

% Read phase from file if requested
if ~isempty(p.Results.phase)
  phase = data(:, p.Results.phase);
  lookupTable = { phase, lookupTable };
end

