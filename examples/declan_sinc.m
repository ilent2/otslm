% Declan's beam script

clear;

x=linspace(-1,1,512);
[X,Y]=meshgrid(x,x);

AI=ones(size(X));
AI(2:2:end,1:2:end)=-1;
AI(1:2:end,2:2:end)=-1;

xg=5;
SX=sinc(xg*X).*exp(-1/10*(X.^2+Y.^2));
SX=SX/max(abs(SX(:)));

c=2/pi*acos(abs(SX));

P=exp(1i*(angle(SX)+(c).*angle(AI)));

FTSX=fftshift(fft2(fftshift(SX)));
SLMSX=fftshift(fft2(fftshift(P)));

figure(1)
imagesc(abs(FTSX));
cx=caxis;
figure(2)
imagesc(abs(SLMSX));
caxis(cx)
figure(3)
imagesc(angle(P));
title('SLM phase pattern - With Alias');
axis('image');