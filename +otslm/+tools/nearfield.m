function pattern = nearfield(target, varargin)
% NEARFIELD generates near-field plane images of target plane pattern

% TODO: Do we need this?
% TODO: Should visualise be renamed to farfield?
% TODO: Should this be combined with visualise?

p = inputParser;
p.addParameter('incident', []);
p.parse(varargin{:});

incident = p.Results.incident;

% Handle default value for incident
if isempty(incident)
  [xx, yy] = meshgrid(1:size(target, 2), 1:size(target, 1));
  xx = xx - size(target, 2)/2;
  yy = yy - size(target, 1)/2;
  sigma = 0.25 * min(size(target));
  incident = exp(-(xx.^2 + yy.^2)./(2*sigma^2));
  incident = incident ./ max(incident(:));
end

% Calculate pattern at DOE
pattern = fftshift(ifft2(fftshift(target)));

% Subtract incident beam
pattern = pattern ./ incident;

