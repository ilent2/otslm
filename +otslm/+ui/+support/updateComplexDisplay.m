function updateComplexDisplay(pattern, slm, ptype, display_type, ax, output_name)
% updateComplexDisplay helper for the display on simple uis with ptype
%
% updateComplexDisplay(pattern, slm, ptype, display_type, ax, output_name)
% Generates the display pattern, updates the axis and outputs to base.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Generate the pattern to display
dpattern = [];
switch display_type
    case 'phase'
        switch ptype
            case 'complex'
                dpattern = angle(pattern);
            case 'phase'
                dpattern = otslm.tools.finalize(pattern, 'colormap', 'pmpi');
            case 'amplitude'
                dpattern = ones(size(pattern));
            otherwise
                error('Invalid drop down value');
        end
    case 'raw'
        switch ptype
            case 'complex'
                dpattern = abs(pattern);
            case 'phase'
                dpattern = pattern;
            case 'amplitude'
                dpattern = pattern;
            otherwise
                error('Invalid drop down value');
        end
    case 'device'
        if ~isempty(slm)
            if strcmpi(ptype, 'complex')
                dpattern = slm.viewComplex(pattern);
            else
                dpattern = slm.view(pattern);
            end
        else
            warning('Device not setup');
        end
    case 'farfield'
        if strcmpi(ptype, 'phase')
            dpattern = otslm.tools.finalize(pattern, 'colormap', 'pmpi');
        else
            dpattern = pattern;
        end
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
