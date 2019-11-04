% Demonstrate iter.CombineGerchbergSaxton
%
% This example attempts to make an array of 10x10 point traps
% using random superposition and otslm.iter.CombineGerchbergSaxton.
%
% Tip: explore changing the 'weighted' and 'adaptive' inputs to
% the CombineGerchbergSaxton constructor.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

h = figure();

%% Setup target spot arrays

sz = [512, 512];

numc = 100;
components = zeros([sz, numc]);
% for ii = 1:numc
%   components(:, :, ii) = otslm.simple.linear(sz, randn(1, 2).*50);
%   if rand() > 0.5
%     components(:, :, ii) = components(:, :, ii) ...
%         + otslm.simple.lgmode(sz, 2, 0);
%   end
% end
for ii = 1:10
  for jj = 1:10
    components(:, :, (ii-1)*10 + jj) = otslm.simple.linear(sz, 64./[ii-5, jj-5]);
  end
end

%% Calculate random superposition (for comparison and initial guess)

comb = otslm.tools.combine(num2cell(components, [1, 2]));

comb = otslm.tools.finalize(comb);
farfield = otslm.tools.visualise(comb, 'trim_padding', true);

figure(h);
subplot(2, 2, 1);
imagesc(abs(farfield)), axis image;
subplot(2, 2, 2);
imagesc(comb), axis image;

%% Test the iterative method

% We could also use a random guess
% rguess = rand(sz);

mtd = otslm.iter.CombineGerchbergSaxton(2*pi*components, ...
  'guess', comb, 'weighted', true, 'adaptive', 1.0);
mtd.run(10);

farfield = otslm.tools.visualise(mtd.phase, 'trim_padding', true);

figure(h);
subplot(2, 2, 3);
imagesc(abs(farfield)), axis image;
subplot(2, 2, 4);
imagesc(mtd.phase), axis image;
