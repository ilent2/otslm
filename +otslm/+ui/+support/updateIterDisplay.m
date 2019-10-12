function updateIterDisplay(pattern, slm, display_type, ax, ...
    output_name, fitness_method)
% updateSimpleDisplay helper for updating the display on iterative uis
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

