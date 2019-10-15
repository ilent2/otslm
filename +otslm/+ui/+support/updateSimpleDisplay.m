function updateSimpleDisplay(pattern, slm, display_type, ax, output_name)
% Helper for updating the display on simple uis.
%
% Usage
%   updateSimpleDisplay(pattern, slm, display_type, ax, output_name)
%   Generates the display pattern, updates the axis and outputs to the
%   base workspace.
%
% Parameters
%   - pattern -- pattern to be displayed
%   - slm -- showable device displaying pattern (or ``[]``)
%   - display_type -- mode for the preview window.
%     can be 'Phase mask', 'Raw phase mask', 'Device image',
%     or 'Simulated farfield'
%   - ax -- axis to place the preview in
%   - output_name -- output variable name in base workspace (or ``[]``)
%
% This function generates the pattern to display in the preview axis.
% If ``output_name`` is not empty, the function also writes the
% pattern to the specified variable name.
%
% This function is used by most of the simple GUIs including
% :class:`ui.simple.linear`, :class:`ui.simple.random`, and
% :class:`ui.tools.combine`. For example usage,
% see :func:`simplePatternValueChanged`.
%
% See also :func:`updateComplexDisplay` and :func:`updateIterDisplay`.

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
