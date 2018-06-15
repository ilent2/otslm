function pattern = finalize(pattern, varargin)
% FINALIZE finalize a pattern, applying a color map and taking the modulo.
%
%   pattern = finalize(input, varargin) finalizes the pattern.
%
% Optional named parameters:
%
%   'modulo'    mod     Applies modulo to the pattern, default 1.0.
%   'colormap'  lookup  Applies the nearest value colour map lookup.
%       May also be:
%         'pmpi' for -pi to pi range.
%         '2pi' for 0 to 2*pi range.

p = inputParser;
p.addParameter('modulo', 1.0);
p.addParameter('colormap', 'pmpi');
p.parse(varargin{:});

if ~isempty(p.Results.modulo)
  pattern = mod(pattern, p.Results.modulo);
end

% Apply colour map
if ischar(p.Results.colormap)
  switch p.Results.colormap
    case 'pmpi'
      pattern = pattern*2*pi - pi;
    case '2pi'
      pattern = pattern*2*pi;
    otherwise
      error('Unrecognized colormap string');
  end
else
  % TODO: Lookup tables
  error('Other colourmaps not yet implemented');
end
