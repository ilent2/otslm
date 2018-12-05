% Demonstration of the screen device class (used to control SLM/DMDs)
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Add toolbox to the path
addpath('../');

%% Create a test device to fill monitor 1

scsz = get(0,'ScreenSize');
target_size = fliplr(scsz(1, 3:4));

slm = otslm.utils.ScreenDevice(1, 'target_size', target_size, ...
  'target_offset', [0, 0], 'pattern_type', 'phase', 'fullscreen', true);

%% Generate a simple pattern and show for 10 seconds

pattern = otslm.simple.linear(slm.size, 50);
slm.show(pattern);
pause(10);
slm.close();

%% Generate a movie of images and display on the device

% Generate images first
patterns = struct('cdata', {}, 'colormap', {});
for ii = 1:100
  patterns(ii) = im2frame(otslm.tools.finalize(pattern + ii/100, ...
      'colormap', slm.lookupTable));
end

% Then display the animation
slm.showRaw(patterns, 'framerate', 100);
slm.close();

%% Create a device by loading a lookup table

% First generate the 'fake' lookup table and write it to a file
% The first column is junk, the second column is the 16 bit table
fake_lookup_table = [rand(2^16-1, 1), (0:(2^16-2)).'];
fname = [tempname, '.txt'];
fp = fopen(fname, 'w');
fprintf(fp, 'The header line...\n');
fprintf(fp, '%f\t%f\n', fake_lookup_table.');
fclose(fp);

% Load the lookup table from file
%   Both the red and green channels use the second column of the
%   data file.  The column has uint16 format.  Red uses the lower
%   8 bits, green uses the upper 8 bits.  The bits are ordered 1:8.
lookup_table = otslm.utils.LookupTable.load(fname, ...
  'channels', [2, 2, 0], 'phase', [], 'format', @uint16, ...
  'mask', [hex2dec('00ff'), hex2dec('ff00')], 'morder',  1:8);

% Create a SLM screen object to control the screen
slm = otslm.utils.ScreenDevice(1, 'target_size', target_size, ...
    'target_offset', [0, 0], 'lookup_table', lookup_table, ...
    'pattern_type', 'phase', 'fullscreen', true);

% Show the pattern for 10 seconds
slm.show(pattern);
pause(10);
slm.close();
