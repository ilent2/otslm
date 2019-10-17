function pattern = lensesAndPrisms(sz, xyz, varargin)
% Generates a hologram using the Lenses and Prisms algorithm
%
% This function has the same affect as using multiple linear
% gratings and spherical lenses combined using otslm.tools.combine.
% The advantage of this function is a smaller memory footprint.
%
% Usage
%   pattern = lensesAndPrisms(sz, xyz, ...)
%   The output pattern is in the range [0, 1).  If supplied, the lens,
%   xgrad and ygrad functions should have range [0, 1).
%
% Parameters
%   - sz (size) -- size of the pattern ``[rows, cols]``
%   - xyz (numeric) -- 3xN matrix for target spot locations.
%     Each column describes a different target, the first two rows
%     describe the linear gradient and the final row describes the lens
%     magnitude.
%
% Optional named parameters
%  - 'lens'       -- pattern to use for lens.
%    (default: xx^2 + yy^2 where xx and yy are from otslm.simple.grid)
%  - 'xgrad'      -- pattern to use for x gradient.
%    (default: xx from otslm.simple.grid)
%  - 'ygrad'      -- pattern to use for y gradient.
%    (default: yy from otslm.simple.grid)
%  - 'amplitude'  -- vector of amplitudes for each location
%  - 'gpuArray' (logical) -- True if the result should be a gpuArray

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Parse inputs
p = inputParser;
p.addParameter('lens', []);
p.addParameter('xgrad', []);
p.addParameter('ygrad', []);
p.addParameter('amplitude', ones(1, size(xyz, 2)));
p.addParameter('gpuArray', []);
p.parse(varargin{:});

assert(numel(p.Results.amplitude) == size(xyz, 2), ...
  'Number of amplitudes must match number of columns of xyz');
assert(size(xyz, 1) == 3, 'xyz must be 3xN matrix');

% Get default gpuArray value
useGpuArray = p.Results.gpuArray;
if isempty(useGpuArray)
  if isa(p.Results.lens, 'gpuArray') ...
      || isa(p.Results.xgrad, 'gpuArray') ...
      || isa(p.Results.ygrad, 'gpuArray')
    useGpuArray = true;
  else
    useGpuArray = false;
  end
end

% Get user supplied arrays
lens = p.Results.lens;
xgrad = p.Results.xgrad;
ygrad = p.Results.ygrad;

% Generate grid if required
if isempty(lens) || isempty(xgrad) || isempty(ygrad)
  [xx, yy, rr] = otslm.simple.grid(sz, 'gpuArray', useGpuArray);
  
  if isempty(lens)
    lens = rr.^2;
  end
  
  if isempty(xgrad)
    xgrad = xx;
  end
  
  if isempty(ygrad)
    ygrad = yy;
  end
end

% Check sizes of inputs
assert(all(size(lens) == sz), 'Lens size must match sz');
assert(all(size(xgrad) == sz), 'xgrad size must match sz');
assert(all(size(ygrad) == sz), 'ygrad size must match sz');

% Ensure we use gpuArray if requested
if useGpuArray
  lens = gpuArray(lens);
  xgrad = gpuArray(xgrad);
  ygrad = gpuArray(ygrad);
end

% Allocate memory for output
pattern = zeros(size(lens), 'like', lens);

% Generate the pattern
for ii = 1:size(xyz, 2)
  pattern = pattern + p.Results.amplitude(ii) .* exp(1i*2*pi* ...
    (xyz(3, ii)*lens + xyz(1, ii)*xgrad + xyz(2, ii)*ygrad));
end

% Scale the pattern between 0 and 1
pattern = (angle(pattern)/pi+1)/2;

% If the user didn't request a gpuArray, gather it
if ~useGpuArray && isa(pattern, 'gpuArray')
  pattern = gather(pattern);
end
