% hologram2bsc_multibeam Fast generation of multiple BSC beams
%
% Demonstrate new features added to hologram2bsc to improve performance
%
% ilent2, 2019

% Add otslm and ott to the path
addpath('../../');
addpath('../../../ott');

% Create a beam and keep the coefficient matrix
% This may take longer but subsequent runs should be faster
pattern = otslm.simple.linear([256, 256], 100);
tic
beam = otslm.tools.hologram2bsc(pattern, ...
  'Nmax', 30, 'NA', 1.02, ...
  'keep_coefficient_matrix', true);
toc
figure(), beam.visualise();

% We can now access the coefficient data
icm = beam.inv_coefficient_matrix;

% You could save this to a file and load it later without re-running the above
%save('icm_nm30_na102.mat', 'icm');
%load('icm_nm30_na102.mat');

% You can then use either the beam or icm to generate new beams
% This one uses the beam
pattern2 = otslm.simple.linear([256, 256], 50);
tic
beam2 = otslm.tools.hologram2bsc(pattern2, ...
  'Nmax', 30, 'NA', 1.02, ...
  'beamData', beam);
toc
figure(), beam2.visualise();

% This one uses the icm
pattern3 = otslm.simple.linear([256, 256], 25);
tic
beam3 = otslm.tools.hologram2bsc(pattern3, ...
  'Nmax', 30, 'NA', 1.02, ...
  'beamData', icm);
toc
figure(), beam3.visualise();

% Both of these should be much faster than the original
% But you need to make sure you have the same Nmax, NA and refractive index

