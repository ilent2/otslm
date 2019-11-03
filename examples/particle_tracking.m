% Simulate particles being imaged using SLM/QPD system
%
% This example is a more complete example of how the toolbox can be
% used to simulate a complete optical system involving a SLM.
%
% In this example, a particle on a microscope slide is imaged
% onto a SLM which displays a grating that deflects the light
% onto a QPD located some distance away from the SLM (but not
% necesarily in the Fourier plane.
%
% The example demonstrates: region sampling, spatial filtering,
% visualisation using fourier transform and simulating of
% absorbing and transparent particles.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Add toolbox to the path
addpath('../');

% Declare parameters for simulation
sz = [512, 512];        % Pattern size (pixels)
r_particle = 10;        % Radius of particle (pixels)
x_particle = 5;         % Particle offset from centre (pixels)
r_slm = 60;             % Size of SLM ROI (pixels)
r_pinhole = 100;         % Size of spatial filter (pixels)
particle_type = 'absorbing';

%% Generate incident illumination
incident = ones(sz);

%% Add the particle and generate image of focal plane

particle_centre = round([x_particle+sz(2)/2, sz(1)/2]);

switch particle_type
  case 'absorbing'

    % Add a absorbing particle
    particle = otslm.simple.aperture(sz, r_particle, ...
        'shape', 'circle', 'centre', particle_centre);
    image_fp = incident;
    image_fp(particle) = 0.0;
    
  case 'spherical'
    
    % Generate a particle that imparts a phase shift
    phase_scale = 0.5;
    
    particle = otslm.simple.spherical(sz, r_particle, ...
      'centre', particle_centre, 'background', 0.0);
    particle = otslm.tools.finalize(particle*phase_scale);
    image_fp = incident .* exp(1i*particle);
    
  otherwise
    error('Unknown particle type');
end

%% Simulate spatial resolution loss of imaging system

pinhole = otslm.simple.aperture(sz, r_pinhole, 'shape', 'circle');
image_slm = otslm.tools.spatial_filter(image_fp, pinhole);

figure();
subplot(3, 2, 1);
imagesc(abs(image_fp));
% imagesc(angle(image_fp));
title('Light at focal plane');
axis image;
subplot(3, 2, 3);
imagesc(abs(image_slm));
title('Light at SLM plane');
axis image;

subplot(3, 2, 2);
imagesc(pinhole);
title('Pinhole (objective)');
axis image;

%% Generate sampling pattern for slm

% Apply an angle to avoid numerical noise from fft
grating = otslm.simple.linear(sz, 10, 'angle_deg', 45);
slm_roi = otslm.simple.aperture(sz, r_slm, 'shape', 'circle');

% TODO: try different ROI mask techniques (test sample_region.m)

slm_pattern = grating;
slm_pattern(~slm_roi) = 0;
slm_pattern = otslm.tools.finalize(slm_pattern);

subplot(3, 2, 4);
imagesc(slm_pattern);
title('SLM Pattern');
axis image;

%% Generate far-field image of SLM

image_slmfarfield = otslm.tools.visualise(slm_pattern, ...
    'incident', image_slm, 'padding', size(slm_pattern)/2, ...
    'method', 'fft', 'trim_padding', true);
  
subplot(3, 2, 5);
imagesc(log10(abs(image_slmfarfield).^2));
title('SLM Far-field (log)');
axis image;
  
%% Add a QPD with a lenslet and view image on the QPD surface

% The lenslet only sample light from a small region
qpd_lens_aperture = otslm.simple.aperture(sz, 50, ...
  'centre', [330, 184], 'value', [true, false]);

image_qpdfarfield = image_slmfarfield;
image_qpdfarfield(qpd_lens_aperture) = 0.0;

% figure(), imagesc(abs(image_qpdfarfield).^2);

% Simualte the lenslet, calculate the farfield (i.e. the qpd plane)
image_qpdplane = otslm.tools.visualise(image_qpdfarfield, ...
    'padding', size(image_qpdfarfield)/2, ...
    'method', 'fft', 'trim_padding', true, 'type', 'nearfield');
  
subplot(3, 2, 6);
imagesc(abs(image_qpdplane).^2);
title('QPD plane image');
axis image;
