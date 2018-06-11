function pattern = combine(inputs, varargin)
% COMBINE combines multiple patterns
%
% pattern = combine(inputs, ...) combines the cell array of patterns.
%
% Optional named parameters:
%
%   'method'    method    Method to use when combinging patterns.
%       Supported methods:
%         expangle      Uses angle(\sum_ii exp(1i*2*pi*inputs(ii)))
%         add           Adds the patterns: \sum_ii inputs(ii)
%         multiply      Multiplies the patterns: \prod_ii inputs(ii)
%         dither        Randomly chooses values from different patterns
%       Default method: expangle.
%
%   'weights'   [weights] Array of weights for each pattern.
%       If the method is dither, this is the percentage of each pattern
%       to include in the result.  Not yet used by other methods.

p = inputParser;
p.addParameter('method', 'expangle');
p.addParameter('weights', []);
p.parse(varargin{:});

switch p.Results.method
  case 'expangle'

    pattern = zeros(size(inputs{1}));

    for ii = 1:length(inputs)
      pattern = pattern + exp(1i*2*pi*inputs{ii});
    end

    pattern = angle(pattern);

  case 'add'

    pattern = zeros(size(inputs{1}));

    for ii = 1:length(inputs)
      pattern = pattern + inputs{ii};
    end

  case 'multiply'

    pattern = zeros(size(inputs{1}));

    for ii = 1:length(inputs)
      pattern = pattern .* inputs{ii};
    end

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
    error('Unknown method');
end

