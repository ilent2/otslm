
addpath('../');

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

%% Generate plot

figure();
loglog(sz, [times; timesGpu; timesGpuG]);
legend({'CPU', 'GPU', 'GPUwG'});

%% Test gratings and lenses approach

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

%% Generate figure

figure();
loglog(sz, [times; timesGpu; timesGpuG]);
legend({'CPU', 'GPU', 'GPUwG'});
title('Slow gratings and lenses?');

%% Use the gratings and lenses function

sz = logspace(1, 4, 20);
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

%% Generate figure

figure();
loglog(sz, [times; timesGpu; timesGpuG]);
legend({'CPU', 'GPU', 'GPUwG'});
title('Dedicated gratings and lenses');


%% Look at scaling with number of traps

sz = [512, 512];
numt = logspace(0, 2, 20);
times = zeros(size(sz));
timesGpu = zeros(size(sz));
timesGpuG = timesGpu;

for ii = 1:length(numt)
  
  xyz = randn(3, round(numt(ii)));
  
  tic
  useGpuArray = true;
  pattern = otslm.tools.lensesAndPrisms(sz, xyz, ...
    'gpuArray', useGpuArray);
  timesGpu(ii) = toc();
  pattern = gather(pattern);
  timesGpuG(ii) = toc();
  
  tic
  useGpuArray = false;
  pattern = otslm.tools.lensesAndPrisms(sz, xyz, ...
    'gpuArray', useGpuArray);
  times(ii) = toc();
  
end

%% Generate figure

figure();
loglog(numt, [times; timesGpu; timesGpuG]);
legend({'CPU', 'GPU', 'GPUwG'});
xlabel('Number of traps');
title('Dedicated gratings and lenses');