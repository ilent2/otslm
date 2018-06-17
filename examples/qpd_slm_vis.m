% Simulate particles being imaged using SLM/QPD system

% Add toolbox to the path
addpath('../');

% Declare parameters for simulation
sz = [512, 512];        % Pattern size (pixels)
r_particle = 5;        % Radius of particle (pixels)
x_particle = 0;         % Particle offset from centre (pixels)
z_qpd = 0.0;            % Offset of qpd plane from Fourier plane (units?)
r_slm = 15;             % Size of SLM ROI (pixels)
r_pinhole = 100;         % Size of spatial filter (pixels)
padding = 800;          % Padding for FT (pixels)
particle_type = 'spherical';

%% Generate incident illumination
incident = ones(sz);

%% Add the particle and generate image of focal plane

particle_centre = round([x_particle+sz(2)/2, sz(1)/2]);

switch particle_type
  case 'absorbing'

    % Add a absorbing particle
    particle = otslm.simple.aperture(sz, r_particle, ...
        'type', 'circle', 'centre', particle_centre);
    image_fp = incident;
    image_fp(particle) = 0.0;
    
  case 'spherical'
    
    % Generate a particle that imparts a phase shift
    phase_scale = 0.5;
    
    particle = otslm.simple.spherical(sz, r_particle, ...
      'centre', particle_centre, 'imag_value', 0.0);
    particle = otslm.tools.finalize(particle*phase_scale);
    image_fp = incident .* exp(1i*particle);
    
  otherwise
    error('Unknown particle type');
end

%% Simulate spatial resolution loss of imaging system

pinhole = otslm.simple.aperture(sz, r_pinhole, 'type', 'circle');
image_slm = otslm.tools.spatial_filter(image_fp, pinhole, ...
    'padding', padding);

figure();
subplot(3, 2, 1);
imagesc(abs(image_fp));
% imagesc(angle(image_fp));
title('Light at focal plane');
subplot(3, 2, 2);
imagesc(abs(image_slm));
title('Light at SLM plane');

subplot(3, 2, 3);
imagesc(pinhole);
title('Pinhole');

%% Generate sampling pattern for slm

% Apply an angle to avoid numerical noise from fft
grating = otslm.simple.linear(sz, 'spacing', 5, ...
    'angle_deg', 45);
slm_roi = otslm.simple.aperture(sz, r_slm, 'type', 'circle');

% TODO: try different ROI mask techniques (test sample_region.m)

slm_pattern = grating;
slm_pattern(~slm_roi) = 0;
slm_pattern = otslm.tools.finalize(slm_pattern);

subplot(3, 2, 4);
imagesc(slm_pattern);
title('SLM Pattern');

%% Generate image in plane of QPD

image_qpdplane = otslm.tools.visualise(slm_pattern, ...
    'incident', image_slm, 'type', 'farfield', 'z', z_qpd, ...
    'method', 'fft', 'padding', padding);
  
%% Display QPD plane image and QPD ROI

image_qpd = image_qpdplane(padding+340+(1:400), padding+340+(1:400));

subplot(3, 2, 5);
imagesc(abs(image_qpdplane));
title('QPD plane intensity');
subplot(3, 2, 6);
imagesc(abs(image_qpd));
title('QPD region of interest');
