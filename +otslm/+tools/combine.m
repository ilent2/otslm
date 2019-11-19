function pattern = combine(inputs, varargin)
% Combines multiple patterns
%
% Typical input should be a pattern between 0 and 1.
% Most methods output range is between 0 and 1.
%
% For iterative combination methods, see :class:`otslm.iter.IterCombine`
% or generate a target field using the ``farfield`` method and use an
% :class:`otslm.iter.IterBase` iterative method.
%
% Usage
%   pattern = combine(inputs, ...) combines the cell array of patterns.
%
% Parameters
%   - inputs (cell) -- cell array of input images to combine.
%     These images should all be the same size.
%
% Optional named parameters
%   - 'method' (enum) -- Method to use when combining patterns.
%
%       Methods to create multiple beams
%         - dither   --   Randomly chooses values from different patterns
%         - super    --   Uses phi = angle(\sum_ii exp(1i*2*pi*inputs(ii)))
%         - rsuper   --   Superposition with random offset for each layer
%
%       Methods to modulate a beam pattern
%         - add      --   Adds the patterns: \sum_ii inputs(ii)
%         - multiply --   Multiplies the patterns: \prod_ii inputs(ii)
%         - addangle --   Uses phi = angle(\prod_ii exp(1i*2*pi*inputs(ii)))
%         - average  --   Weighted average of inputs.  (default weights: ones)
%           :math:`\sum_i w_i I_i / \sum_i w_i`
%
%       Miscelanious
%         - farfield --   Calculate farfield sum: \sum_ii Prop(inputs(ii)).
%           This method assumes the input has the currect range for the
%           propagator.  The default propagator is a FFT, so the inputs
%           should be complex amplitudes.
%
%       Default method: super.
%
%   - 'weights' (numeric) -- Array of weights, one for each pattern.
%     (default: [], uses equal weights for each pattern)
%
%   - 'vismethod' (fcn) -- Used by ``farfield`` method.
%     Default: ``@otslm.tools.prop.FftForward.simpleProp.evaluate``.
%
% See also Di Leonardo, Ianni and Ruocco (2007).

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% TODO: Do we want to include some nice defaults for GS, GSW, GAA?

p = inputParser;
p.addParameter('method', 'super');
p.addParameter('weights', []);
p.addParameter('vismethod', []);
p.parse(varargin{:});

% Check that we have work to do
assert(~isempty(inputs), 'Inputs must have at least one element');

% Get weights and calculate normalized weights
weights = p.Results.weights;
if isempty(weights)
  weights = ones(length(inputs), 1);
end
nweights = weights ./ sum(weights);


switch p.Results.method
  case 'super'

    pattern = zeros(size(inputs{1}));

    for ii = 1:length(inputs)
      pattern = pattern + nweights(ii).*exp(1i*2*pi*inputs{ii});
    end

    pattern = (angle(pattern)/pi+1)/2;

  case 'rsuper'

    offsets = rand([1, length(inputs)])*2*pi;

    pattern = zeros(size(inputs{1}));

    for ii = 1:length(inputs)
      pattern = pattern + nweights(ii).*exp(1i*2*pi*inputs{ii} + 1i*offsets(ii));
    end

    pattern = (angle(pattern)/pi+1)/2;
    
  case 'farfield'
    
    % Handle default visualisation method
    vismethod = p.Results.vismethod;
    if isempty(vismethod)
      prop = otslm.tools.prop.FftForward.simpleProp(inputs{1}, ...
          'gpuArray', isa(inputs{1}, 'gpuArray'));
      vismethod = @prop.propagate;
    end

    % Combine patterns
    pattern = nweights(1).*vismethod(inputs{1});
    for ii = 2:length(inputs)
      pattern = pattern + nweights(ii).*vismethod(inputs{ii});
    end
    pattern = pattern ./ length(inputs);

  case 'add'

    pattern = zeros(size(inputs{1}));

    for ii = 1:length(inputs)
      pattern = pattern + weights(ii).*inputs{ii};
    end

  case 'average'

    pattern = zeros(size(inputs{1}));

    weights = p.Results.weights;
    if isempty(weights)
      weights = zeros(length(inputs), 1);
    end

    for ii = 1:length(inputs)
      pattern = pattern + weights(ii).*inputs{ii};
    end

    pattern = pattern ./ sum(weights(:));

  case 'multiply'

    pattern = zeros(size(inputs{1}));

    for ii = 1:length(inputs)
      pattern = pattern .* inputs{ii};
    end

  case 'addangle'

    pattern = ones(size(inputs{1}));
    for ii = 1:length(inputs)
      pattern = pattern .* exp(1i*2*pi*inputs{ii});
    end

    pattern = (angle(pattern)/pi+1)/2;

  case 'dither'
    
    cweights = cumsum(nweights);

    % Generate the pattern
    pattern = zeros(size(inputs{1}));
    
    % Deterimine which pixels are which index
    idxs = rand(size(pattern));
    idxs = idxs(:) - cweights(:).';
    idxs(idxs >= 0) = NaN;
    [~, idxs] = max(idxs, [], 2);
    
    % Merge the images
    for ii = 1:length(inputs)
      pattern(idxs == ii) = inputs{ii}(idxs == ii);
    end

  otherwise
    error('Unknown combination method');
end

