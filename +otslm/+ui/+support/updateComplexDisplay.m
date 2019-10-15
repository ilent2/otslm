function updateComplexDisplay(pattern, slm, ptype, display_type, ax, output_name)
% Helper for the display on simple uis with ptype
%
% Usage
%   updateComplexDisplay(pattern, slm, ptype, display_type, ax, output_name)
%   Generates the display pattern, updates the axis and outputs to base.
%
% Parameters
%   - pattern -- pattern to be displayed
%   - slm -- showable device displaying pattern (or ``[]``)
%   - ptype -- type of pattern.  Must be 'phase', 'amplitude' or 'complex'.
%   - display_type -- mode for the preview window.
%     can be 'phase', 'raw', 'device', or 'farfield'.
%   - ax -- axis to place the preview in
%   - output_name -- output variable name in base workspace (or ``[]``)
%
% As per :func:`updateSimpleDisplay` but with complex patterns and
% an additional ``ptype`` argument.
%
% See also :func:`updateIterDisplay` and
% :func:`complexPatternValueChanged`

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
