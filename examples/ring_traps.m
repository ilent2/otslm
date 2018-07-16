% Generate ring traps

sz = [512, 512];
padding = 500;

%% Calculate fourier transoform of a ring
% first lets look at what a ring looks like in the far-field

r1 = 50;
r2 = r1 + 50;

apperture1 = otslm.simple.aperture(sz, r1);
apperture2 = otslm.simple.aperture(sz, r2);

amplitude = 1.0*apperture2 - 1.0*apperture1;

% amplitude = 1.0 - apperture1;

subplot(1, 3, 1);
imagesc(amplitude);

nearfield = otslm.tools.visualise(zeros(sz), 'amplitude', amplitude, ...
    'method', 'fft', 'padding', padding, 'incident', ones(sz));
  
o = 300;
nearfield = nearfield((-o:o)+ceil(size(nearfield, 1)/2), (-o:o)+ceil(size(nearfield, 2)/2));
  
subplot(1, 3, 2);
imagesc(abs(nearfield));

subplot(1, 3, 3);
imagesc(angle(nearfield));

plot(abs(nearfield(ceil(size(nearfield, 1)/2), :)));

%% Lets try mixing two sincs together

sinc1 = otslm.simple.sinc(sz, 3);
sinc2 = otslm.simple.sinc(sz, 30);

pattern = sinc2 .* sinc1;
plot(abs(pattern(ceil(size(pattern, 1)/2), :)));

pattern = otslm.tools.finalize(zeros(sz), 'amplitude', pattern);
farfield = otslm.tools.visualise(pattern, 'method', 'fft', 'padding', padding);


farfield = farfield((-o:o)+ceil(size(farfield, 1)/2), ...
    (-o:o)+ceil(size(farfield, 2)/2));

figure(1);
imagesc(abs(farfield).^2);
% imagesc(pattern);

% plot(abs(farfield(ceil(size(farfield, 1)/2), :)).^2);
