% Calculate the phase from a target amplitude pattern

sz = [512, 512];

target = otslm.simple.aperture(sz, [5, 1], ...
    'type', 'rect', 'centre', sz/2 + [20, 20]);

figure(1);
imagesc(target);

nearfield = otslm.tools.nearfield(target);

figure(2);
subplot(1, 2, 1);
imagesc(abs(nearfield));
subplot(1, 2, 2);
imagesc(angle(nearfield));
