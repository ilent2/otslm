function pattern = combine(inputs, varargin)
% Combines multiple patterns
%
% Typical input should be a pattern between 0 and 1.
% Most methods output range is between 0 and 1.
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
%         - gs       --   Applies GS algorithm to try and generate the
%           pattern that would be created by the sum of the individual
%           beams.  Starts with an initial guess using rsuper.
%
%       Methods to modulate a beam pattern
%         - add      --   Adds the patterns: \sum_ii inputs(ii)
%         - multiply --   Multiplies the patterns: \prod_ii inputs(ii)
%         - addangle --   Uses phi = angle(\prod_ii exp(1i*2*pi*inputs(ii)))
%         - average  --   Weighted average of inputs.  (default weights: ones)
%           :math:`\sum_i w_i I_i / \sum_i w_i`
%
%       Default method: super.
%
%   - 'weights' (numeric) -- Array of weights, one for each pattern.
%     (default: [], uses equal weights for each pattern)
%
% See also Di Leonardo, Ianni and Ruocco (2007).

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('method', 'super');
p.addParameter('weights', []);
p.parse(varargin{:});

% Check that we have work to do
assert(~isempty(inputs), 'Inputs must have at least one element');

% Get weights and calculate normalized weights
weights = p.Results.weights;
if isempty(weights)
  weights = ones(length(inputs), 1);
end
nweights = ones(size(weights)); %weights ./ sum(weights);


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

  case 'gs'

    % Calculate initial guess using random phase superposition
    guess = otslm.tools.combine(inputs, varargin{:}, ...
        'method', 'rsuper');

    incident = ones(size(inputs{1}));

    % Calculate the target using fft
    target = zeros(size(inputs{1}));
    for ii = 1:length(inputs)
      padding = size(target)./2;
      vis = otslm.tools.visualise(2*pi*inputs{ii}, ...
          'incident', incident, 'method', 'fft', 'padding', padding, ...
          'trim_padding', true);
      target = target + nweights(ii).*abs(vis).^2;
    end
    target = target ./ length(inputs);
    
    % Setup visualisation function
    prop = otslm.tools.prop.FftForward.simpleProp(target, ...
        'gpuArray', isa(target, 'gpuArray'));
    vismethod = @(U) prop.propagate(U .* incident);

    % Calculate the pattern with GS algorithm
    gs = otslm.iter.GerchbergSaxton(target, 'guess', 2*pi*guess, ...
        'vismethod', vismethod);
    gs.run(100, 'show_progress', false);

    % Convert pattern to 0-1 range
    pattern = (gs.phase/pi+1)/2;

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

