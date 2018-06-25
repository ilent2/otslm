% Demonstrate the SLM calibration stuff

addpath('../');

sz = [300, 300];

high = linspace(0.0, 2*pi, 10);

%% Test using a step function

testPattern(high, @(h) otslm.simple.step(sz, 'value', [0.0, h]));
  
%% Test using two pinhole regions

testPattern(high, @(h) pinholePattern(sz, h));

%% Function to run the test

function testPattern(high, pattern_method)

  pt = 100;
  padding = 800;

  for ii = 1:length(high)

    figure(1);
    subplot(2, 5, ii);
    pattern = pattern_method(high(ii));
    imagesc(pattern);
    caxis([0.0, 2*pi]);

    figure(2);
    subplot(2, 5, ii);
    farfield = otslm.tools.visualise(pattern, 'method', 'fft', ...
      'padding', padding);
    farfieldpt = farfield((-pt:pt)+ceil(size(farfield, 1)/2), ...
        (-pt:pt)+ceil(size(farfield, 2)/2));
    imagesc(abs(farfieldpt));

    figure(3);
    subplot(2, 5, ii);
    slice = farfieldpt(ceil(size(farfieldpt, 1)/2), :);
    plot(1:length(slice), abs(slice));
  end

end

%% Other functions

function pattern = pinholePattern(sz, h)

  pattern = otslm.simple.step(sz, 'value', [0.0, h]);
  
  r = 10;
  o = 20;
  c1 = [ceil(sz(2)/2)-o, ceil(sz(1)/2)];
  c2 = [ceil(sz(2)/2)+o, ceil(sz(1)/2)];
  
  mask_pinhole1 = otslm.simple.aperture(sz, r, 'centre', c1);
  mask_pinhole2 = otslm.simple.aperture(sz, r, 'centre', c2);
  
  mask = mask_pinhole1 | mask_pinhole2;
  
  % Uniform random noise
%   pattern(~mask) = 2*pi*rand(size(pattern(~mask)));
  
  % Gaussian centred around zero (most likely)
%   scale = 4.0;
%   pattern(~mask) = min(2*pi, scale*abs(randn(size(pattern(~mask)))));

  % Checkerboard
  checker = otslm.simple.checkerboard(sz);
  pattern(~mask) = checker(~mask)*2*pi;

end
