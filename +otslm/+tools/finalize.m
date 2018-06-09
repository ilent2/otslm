function pattern = finalize(input, varargin)
% FINALIZE finalize a pattern, applying a color map and taking the modulo.
%
%   pattern = finalize(input, varargin) finalizes the pattern.
%
% Optional named parameters:
%
%   'modulo'    mod     Applies modulo to the pattern, default 1.0.
%   'colormap'  lookup  Applies the nearest value colour map lookup.

p = inputParser;
p.addParameter('modulo', 1.0);
p.addParameter('colormap', []);
p.parse(varargin{:});

if ~isempty(p.Results.modulo)
  input = mod(input, p.Results.modulo);
end

% TODO: Apply colour map

pattern = input;
