% Demonstration of the GPU capabilities of the toolbox
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

addpath('../');

%% Create a pattern and modify it on the GPU

sz = [1024, 1024];
pattern = otslm.simple.checkerboard(sz, 'gpuArray', true);
lin = otslm.simple.linear(sz, 100, 'gpuArray', true);
ap = otslm.simple.aperture(sz, 512, 'gpuArray', true);

% Combine patterns and finalize
pattern(ap) = lin(ap);
pattern = otslm.tools.finalize(pattern);

% Copy back from the GPU and view
im = gather(pattern);
figure();
imagesc(im);

%% Look at computation time with different sized patterns
% This shows that there is a slight improvement when using the GPU
% for calculating individual patterns.  A larger improvement can be
% found for more complex patterns (see bellow).

sz = logspace(1, 4, 20);
times = zeros(size(sz));
timesGpu = zeros(size(sz));
timesGpuG = timesGpu;

for ii = 1:length(sz)
  tic
  pattern = otslm.simple.checkerboard(round([1,1].*sz(ii)), 'gpuArray', false);
  times(ii) = toc();
  
  tic
  im = otslm.simple.checkerboard(round([1,1].*sz(ii)), 'gpuArray', true);
  timesGpu(ii) = toc();
  im = gather(im);
  timesGpuG(ii) = toc();
  
end

% Generate plot

figure();
loglog(sz, [times; timesGpu; timesGpuG]);
legend({'CPU', 'GPU', 'GPU + Gather'});

%% Test gratings and lenses with combine
% This works ok with a couple of images but for 100s of images we
% quickly run out of memory on the GPU

sz = logspace(1, 3.5, 20);
times = zeros(size(sz));
timesGpu = zeros(size(sz));
timesGpuG = timesGpu;

for ii = 1:length(sz)
  
  tic
  
  useGpuArray = true;

  pattern1 = otslm.simple.linear(round([1,1].*sz(ii)), 30, ...
    'angle_deg', 90, 'gpuArray', useGpuArray);
  lens1 = otslm.simple.spherical(round([1,1].*sz(ii)), ...
    round(sz(ii)*sqrt(2)), 'scale', 10, 'gpuArray', useGpuArray);
  pattern2 = otslm.simple.linear(round([1,1].*sz(ii)), 30, ...
    'angle_deg', 0, 'gpuArray', useGpuArray);
  lens2 = otslm.simple.spherical(round([1,1].*sz(ii)), ...
    round(sz(ii)*sqrt(2)), 'scale', -5, 'gpuArray', useGpuArray);

  pattern = otslm.tools.combine({pattern1+lens1, pattern2+lens2}, ...
    'method', 'super');
  
  timesGpu(ii) = toc();
  pattern = gather(pattern);
  timesGpuG(ii) = toc();
  
  tic
  
  useGpuArray = false;

  pattern1 = otslm.simple.linear(round([1,1].*sz(ii)), 30, ...
    'angle_deg', 90, 'gpuArray', useGpuArray);
  lens1 = otslm.simple.spherical(round([1,1].*sz(ii)), ...
    round(sz(ii)*sqrt(2)), 'scale', 10, 'gpuArray', useGpuArray);
  pattern2 = otslm.simple.linear(round([1,1].*sz(ii)), 30, ...
    'angle_deg', 0, 'gpuArray', useGpuArray);
  lens2 = otslm.simple.spherical(round([1,1].*sz(ii)), ...
    round(sz(ii)*sqrt(2)), 'scale', -5, 'gpuArray', useGpuArray);

  im = otslm.tools.combine({pattern1+lens1, pattern2+lens2}, ...
    'method', 'super');
  
  times(ii) = toc();
  
end

% Generate figure

figure();
loglog(sz, [times; timesGpu; timesGpuG]);
legend({'CPU', 'GPU', 'GPU + Gather'});
title('Gratings and Lenses with Combine');

%% Use the gratings and lenses function
% This test shows how the gratings and lenses function performs similar
% to the previous example.

sz = logspace(1, 3.5, 20);
times = zeros(size(sz));
timesGpu = zeros(size(sz));
timesGpuG = timesGpu;

xyz = randn(3, 2);

for ii = 1:length(sz)
  
  tic
  useGpuArray = true;
  pattern = otslm.tools.lensesAndPrisms(round([1,1].*sz(ii)), xyz, ...
    'gpuArray', useGpuArray);
  timesGpu(ii) = toc();
  pattern = gather(pattern);
  timesGpuG(ii) = toc();
  
  tic
  useGpuArray = false;
  pattern = otslm.tools.lensesAndPrisms(round([1,1].*sz(ii)), xyz, ...
    'gpuArray', useGpuArray);
  times(ii) = toc();
  
end

% Generate figure

figure();
loglog(sz, [times; timesGpu; timesGpuG]);
legend({'CPU', 'GPU', 'GPU + Gather'});
title('Dedicated gratings and lenses');


%% Look at scaling with number of traps
% Run the gratings and lenses algorithm with multiple traps.
% This sometimes produces bad performance on the first run on my
% computer (sometimes Matlab doesn't find the GPU...???)

sz = [512, 512];
numt = unique(round(logspace(0, 2, 20)));
numAvg = 4;
times = zeros(size(numt));
timesGpu = zeros(size(numt));
timesGpuG = timesGpu;

for ii = 1:length(numt)
  
  xyz = randn(3, numt(ii), numAvg);
  
  for jj = 1:numAvg
    tic
    useGpuArray = true;
    pattern = otslm.tools.lensesAndPrisms(sz, xyz(:, :, jj), ...
      'gpuArray', useGpuArray);
    timesGpu(ii) = timesGpu(ii) + toc();
    pattern = gather(pattern);
    timesGpuG(ii) = timesGpuG(ii) + toc();
  end

  for jj = 1:numAvg
    tic
    useGpuArray = false;
    pattern = otslm.tools.lensesAndPrisms(sz, xyz(:, :, jj), ...
      'gpuArray', useGpuArray);
    times(ii) = times(ii) + toc();
  end
  
end

% Generate figure

figure();
loglog(numt, [times; timesGpu; timesGpuG]./numAvg);
hold on;
loglog([min(numt), max(numt)], 1/60 * [1,1], 'k--');
hold off;
legend({'CPU', 'GPU', 'GPU + Gather', '60Hz'}, 'Location', 'NorthWest');
xlabel('Number of traps');
ylabel('Evaluation time [s]');
title('Dedicated gratings and lenses');

%% Using the Gerchberg-Saxton algorithm

% Generate the target image
sz = [512, 512];
im = otslm.simple.aperture(sz, sz(1)/20, 'value', [0, 1], 'gpuArray', true);

% Setup the GS object and then run
gs = otslm.iter.GerchbergSaxton(im, 'adaptive', 1.0, 'objective', []);
tic
pattern = gs.run(600, 'show_progress', false);
toc

figure();
im = abs(otslm.tools.visualise(pattern, 'trim_padding', true).^2);
imagesc(im);

%% Running Prisms and Lenses with RedTweezers

% Connect to red-tweezers
rt = otslm.utils.RedTweezers.PrismsAndLenses();
rt.window= [100, 200, 512, 512];   % Window size [x, y, width, height]

% Configure the prisms and lenses shader
rt.focal_length = 4.5e6;       % Focal length [microns]
rt.wavenumber = 2*pi/1.064;    % Wavenumber [1/microns]
rt.size = [10.2e6, 10.2e6];    % SLM size [microns]
rt.centre = [0.5, 0.5];
rt.total_intensity = 0.0;   % 0.0 to disable
rt.blazing = linspace(0.0, 1.0, 32);
rt.zernike = zeros(1, 12);

% Add some spots
rt.addSpot('position', [60, 54, 7])
rt.addSpot('position', [-20, 10, -3])
rt.addSpot('position', [40, -37, 0])
