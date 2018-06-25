% Checkerboard tests

sz = [200, 200];
padding = 500;

for ii = 1:4
  
  pattern = otslm.simple.checkerboard(sz, 'spacing', ii*2)*2*pi;
  
  figure(1);
  subplot(2, 2, ii);
  imagesc(pattern);
  
  farfield = otslm.tools.visualise(pattern, 'padding', padding);
  
  figure(2);
  subplot(2, 2, ii);
  imagesc(abs(farfield));
  
end