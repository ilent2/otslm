function updateIterDisplay(pattern, slm, display_type, ax, ...
    output_name, fitness_method)
% Helper for updating the display on iterative uis.
%
% Usage
%   updateIterDisplay(pattern, slm, display_type, ax, output_name,
%   fitness_method) generates the display pattern, updates the
%   axis and outputs to base.
%
% Parameters
%   - pattern -- pattern to be displayed
%   - slm -- showable device displaying pattern (or ``[]``)
%   - display_type -- mode for the preview window.
%     can be 'phase', 'error', 'device', or 'farfield'
%   - ax -- axis to place the preview in
%   - output_name -- output variable name in base workspace (or ``[]``)
%   - fitness_method -- function to plot fitness
%
% Similar to :func:`updateSimpleDisplay` but displays either the
% phase pattern, error function, simulated far-field or device
% pattern in the preview window.
%
% This function generates the pattern to display in the preview axis.
% If ``output_name`` is not empty, the function also writes the
% pattern to the specified variable name.
%
% See also :func:`updateComplexDisplay` and :func:`iterPatternValueChanged`.

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Generate the pattern to display
dpattern = [];
switch display_type
    case 'phase'
        dpattern = pattern;
    case 'error'
        cla(ax, 'reset');
        fitness_method();
    case 'device'
        if ~isempty(slm)
            dpattern = slm.view(pattern./(2*pi));
        else
            warning('Device not setup');
        end
    case 'farfield'
        dpattern = otslm.tools.visualise(pattern, 'method', 'fft', 'trim_padding', true, ...
            'padding', ceil(size(pattern)/2), 'incident', ones(size(pattern)));
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

