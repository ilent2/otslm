function updateSimpleDisplay(pattern, slm, display_type, ax, output_name)
% updateSimpleDisplay helper for updating the display on simple uis
%
% updateSimpleDisplay(pattern, slm, display_type, ax, output_name)
% Generates the display pattern, updates the axis and outputs to base.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Generate the pattern to display
dpattern = [];
switch display_type
  case 'Phase mask'
      dpattern = otslm.tools.finalize(pattern, 'colormap', 'pmpi');
  case 'Raw phase mask'
      dpattern = pattern;
  case 'Device image'
      if ~isempty(slm)
          dpattern = slm.view(pattern);
      else
          warning('Device not setup');
      end
  case 'Simulated farfield'
      dpattern = otslm.tools.finalize(pattern, 'colormap', 'pmpi');
      dpattern = otslm.tools.visualise(dpattern, 'method', 'fft', 'trim_padding', true, ...
          'padding', ceil(size(dpattern)/2), 'incident', ones(size(dpattern)));
      dpattern = abs(dpattern).^2;
  otherwise
      error('Invalid drop down option selected');
end

% Show the pattern in the window
if ~isempty(dpattern)
    imagesc(ax, dpattern);
    axis(ax, 'image');
    set(ax, 'xtick', [], 'xticklabel', []);
    set(ax, 'ytick', [], 'yticklabel', []);
end

% Write pattern to workspace
otslm.ui.support.saveVariableToBase(...
  output_name, dpattern, 'Display variable');
