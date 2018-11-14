function pattern = combine(inputs, varargin)
% COMBINE combines multiple patterns
%
% pattern = combine(inputs, ...) combines the cell array of patterns.
%
% Typical input should be a pattern between 0 and 1.
% Most methods output range is between 0 and 1.
%
% See also Di Leonardo, Ianni and Ruocco (2007).
%
% Optional named parameters:
%
%   'method'    method    Method to use when combinging patterns.
%
%       Methods to create multiple beams:
%         dither        Randomly chooses values from different patterns
%         super         Uses phi = angle(\sum_ii exp(1i*2*pi*inputs(ii)))
%         rsuper        Superposition with random offset for each layer
%         gs            Applies GS algorithm to try and generate the
%             pattern that would be created by the sum of the individual
%             beams.  Starts with an initial guess using rsuper.
%
%       Methods to modulate a beam pattern:
%         add           Adds the patterns: \sum_ii inputs(ii)
%         multiply      Multiplies the patterns: \prod_ii inputs(ii)
%         addangle      Uses phi = angle(\prod_ii exp(1i*2*pi*inputs(ii)))
%         average       Weighted average of inputs.  (default weights: ones)
%                           \sum_ii w_ii*inputs(ii) / \sum_ii w_ii
%
%       Default method: super.
%
%   'weights'   [weights] Array of weights for each pattern.
%       If the method is dither, this is the percentage of each pattern
%       to include in the result.  Not yet used by other methods.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

p = inputParser;
p.addParameter('method', 'super');
p.addParameter('weights', []);
p.parse(varargin{:});

% Check that we have work to do
assert(~isempty(inputs), 'Inputs must have at least one element');

switch p.Results.method
  case 'super'

    pattern = zeros(size(inputs{1}));

    for ii = 1:length(inputs)
      pattern = pattern + exp(1i*2*pi*inputs{ii});
    end

    pattern = (angle(pattern)/pi+1)/2;

  case 'rsuper'

    offsets = rand([1, length(inputs)])*2*pi;

    pattern = zeros(size(inputs{1}));

    for ii = 1:length(inputs)
      pattern = pattern + exp(1i*2*pi*inputs{ii} + 1i*offsets(ii));
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
      padding = 0;
      vis = otslm.tools.visualise(2*pi*inputs{ii}, ...
          'incident', incident, 'method', 'fft', 'padding', padding);
      target = target + abs(vis(padding+1:end-padding, padding+1:end-padding));
    end
    target = target ./ length(inputs);

    % Calculate the pattern with GS algorithm
    pattern = otslm.iter.gs(target, 'guess', guess, ...
        'incident', incident);

    pattern = (pattern/pi+1)/2;

  case 'add'

    pattern = zeros(size(inputs{1}));

    for ii = 1:length(inputs)
      pattern = pattern + inputs{ii};
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

    % Get weights and normalize
    weights = p.Results.weights;
    if isempty(weights)
      weights = ones(length(inputs), 1);
    end
    weights = weights ./ sum(weights);

    % Generate the pattern
    pattern = zeros(size(inputs{1}));
    idxs = randi(length(inputs), size(pattern));

    for ii = 1:length(inputs)
      layer = inputs{ii};
      pattern(idxs == ii) = layer(idxs == ii);
    end

  otherwise
    error('Unknown combination method');
end

