function [pattern, amplitude] = igmode(sz, even, modep, modem, elipticity, varargin)
% IGMODE generates phase and amplitude patterns for Ince-Gaussian beams
%
% pattern = igmode(sz, e, p, m, elipticity, ...) generates the phase
% pattern with parity even and polynomial order modep and degree modem.
% p = 0,1,2,3... and 0 <= m <= p.
% elipticity is the elipticity of the coordinates.
%
% [phase, amplitude] = igmode(...) also calculates the signed
% amplitude of the pattern in addition to the phase.
%
% Ince-Gaussian beams are described in Bandres and Gutiérrez-Vega (2004).
%
% Optional named parameters:
%
%   'centre'    [ x, y ]    centre location (default: pattern centre)
%   'scale'     scale       scaling factor for pattern
%   'aspect'    aspect      aspect ratio for pattern
%   'angle'     angle       rotation angle of pattern (radians)
%   'angle_deg' angle       rotation angle of pattern (degrees)
%
% This function uses code from Miguel Bandres, see source code
% for information about copyright/license/distribution.
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

warning('igmode may not produce clean output/needs work');

% Check inputs
assert(even == true || even == false, 'e (even) must be true or false');
assert(modem <= modep && modem >= 0 && ...
    floor(modem) == modem, 'm must be positive integer <= p');
assert(modep >= 0 && floor(modep) == modep, 'p must be positive integer');

p = inputParser;
p.addParameter('centre', [sz(2)/2, sz(1)/2]);
p.addParameter('aspect', 1.0);
p.addParameter('angle', []);
p.addParameter('angle_deg', []);
p.addParameter('scale', sqrt(sz(1)^2 +sz(2)^2)/2);
p.parse(varargin{:});

% Generate coordinates
[xx, yy] = otslm.simple.grid(sz, ...
    'centre', p.Results.centre, 'aspect', p.Results.aspect, ...
    'angle', p.Results.angle, 'angle_deg', p.Results.angle_deg);

% Apply scaling to the coordinates
xx = xx ./ p.Results.scale;
yy = yy ./ p.Results.scale;

% Calculate elliptic coordinates
%   I don't know how to calculate these directly so we will
%   instead generate a grid of points and interpolate the Cartesian coords.

% TODO: The range for these values may be important
%   Should we allow the user to specify them or make a better
%   automatic choice based on the pattern centre, angle and scale?

nu = linspace(0, 2*pi);
mu = linspace(0, 1);

[nug, mug] = meshgrid(nu, mu);

xE = sqrt(elipticity/2).*cosh(mug).*cos(nug);
yE = sqrt(elipticity/2).*sinh(mug).*sin(nug);

% Calculate pattern

if even == true
  amplitudeE = CInce(modep, modem, elipticity, 1i*mu) ...
    .* CInce(modep, modem, elipticity, nu);
else
  amplitudeE = SInce(modep, modem, elipticity, 1i*mu) ...
      .* SInce(modep, modem, elipticity, nu);
end

amplitudeE = amplitudeE .* exp(-(xE.^2 + yE.^2));

% Calculate pattern in Cartesian coordinates
S = warning('off', 'MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId');
F = scatteredInterpolant(xE(:), yE(:), amplitudeE(:));
warning(S);
amplitude = F(xx, yy);

% Normalize amplitude maximum value
amplitude = amplitude ./ max(abs(amplitude(:)));

% Generate phase pattern
pattern = (amplitude >= 0.0) * 0.5;

end

function [IP,eta] = CInce(p, m, q, z, normalization)
% Calculate EVEN Ince polynomials
%
% Copyright (c) 2014, Miguel Bandres
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

%% Check Input
if nargin==4; normalization=0; end;    %
if (m<0)||(m>p); error('ERROR: Wrong range for "m", 0<=m<=p'); end;
if (-1)^(m-p)~=1;   error('ERROR: (p,m) must have the same parity, i.e., (-1)^(m-p)=1');  end;
[largo,ancho]=size(z); % change input to vector format
z=transpose(z(:));

%% Calculate the Coefficients 
if mod(p,2)==0
    %%%% p Even %%%%
    j=p/2;  N=j+1;  n=m/2+1;

    % Matrix
    M=diag(q*(j+(1:N-1)),1) + diag([2*q*j,q*(j-(1:N-2))],-1) + diag([0,4*((0:N-2)+1).^2]);
    if p==0; M=0; end;

    % Eigenvalues and Eigenvectors 
    [A,ets]=eig(M);
    ets=diag(ets); 
    [ets,index]=sort(ets);
    A=A(:,index);

    % Normalization
    if normalization==0;  
       N2=2*A(1,n).^2+sum(A(2:N,n).^2);
       NS=sign(sum(A(:,n)));
       A=A/sqrt(N2)*NS;
    else 
       mv=(2:2:p).';
       N2=sqrt(A(1,n)^2*2*gamma(p/2+1)^2+sum((sqrt(gamma((p+mv)/2+1).*gamma((p-mv)/2+1) ).*A(2:p/2+1,n)).^2 ));
       NS=sign(sum(A(:,n)));
       A=A/N2*NS;
    end

    % Ince Polynomial
    r=0:N-1;
    [R,X]=meshgrid(r,z);
    IP=cos(2*X.*R)*A(:,n);
    eta=ets(n);

else
    %%%% p ODD %%%
    j=(p-1)/2;  N=j+1;  n=(m+1)/2;

    % Matrix
    M=diag(q/2*(p+(2*(0:N-2)+3)),1)+diag(q/2*(p-(2*(1:N-1)-1)),-1) + diag([q/2+p*q/2+1,(2*(1:N-1)+1).^2]);

    % Eigenvalues and Eigenvectors 
    [A,ets]=eig(M);
    ets=diag(ets);
    [ets,index]=sort(ets);
    A=A(:,index);

    % Normalization
    if normalization==0;
       N2=sum(A(:,n).^2);
       NS=sign(sum(A(:,n)));
       A=A/sqrt(N2)*NS;
    else
        mv=(1:2:p).';
        N2=sqrt(sum( ( sqrt(gamma((p+mv)/2+1).*gamma((p-mv)/2+1) ).*A(:,n)).^2 ));
        NS=sign(sum(A(:,n)));
        A=A/N2*NS;
    end

    % Ince Polynomial
    r=2*(0:N-1)+1;  
    [R,X]=meshgrid(r,z);
    IP=cos(X.*R)*A(:,n);
    eta=ets(n);
end

IP=reshape(IP,[largo,ancho]); % reshape output to original format

end

function [IP,eta] = SInce(p, m, q, z, normalization)
% Calculate ODD Ince polynomials
%
% Copyright (c) 2014, Miguel Bandres
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

%% Check Input
if nargin==4; normalization=0; end;    %
if (m<1)||(m>p);  error('ERROR: Wrong range for "m", 1<=m<=p'); end;
if (-1)^(m-p)~=1;   error('ERROR: (p,m) must have the same parity, i.e., (-1)^(m-p)=1');  end;
[largo,ancho]=size(z);  % change input to vector format
z=transpose(z(:));

%% Calculate the Coefficients 
if mod(p,2)==0
    %%%% p Even %%%%
    j=p/2;  N=j+1; n=m/2;

    % Matrix 
    M=diag(q*(j+(2:N-1)),1)+diag(q*(j-(1:N-2)),-1) + diag(4*((0:N-2)+1).^2);

    % Eigenvalues and Eigenvectors 
    [A,ets]=eig(M);
    ets=diag(ets);
    [ets,index]=sort(ets);
    A=A(:,index);

    % Normalization
    r=1:N-1;
    if normalization==0;
       N2=sum(A(:,n).^2);
       NS=sign(sum(r.*transpose(A(:,n))));
       A=A/sqrt(N2)*NS;
    else
        mv=(2:2:p).';
        N2=sqrt(sum((sqrt(gamma((p+mv)/2+1).*gamma((p-mv)/2+1) ).*A(:,n)).^2 ));
        NS=sign(sum(r.*A(:,n)'));
        A=A/N2*NS;
    end

    % Ince Polynomial
    [R,X]=meshgrid(r,z);
    IP=sin(2*X.*R)*A(:,n);
    eta=ets(n);

else
    %%%% p ODD %%%
    j=(p-1)/2; N=j+1; n=(m+1)/2;

    % Matrix
    M=diag(q/2*(p+(2*(0:N-2)+3)),1)+diag(q/2*(p-(2*(1:N-1)-1)),-1) + diag([-q/2-p*q/2+1,(2*(1:N-1)+1).^2]);

    % Eigenvalues and Eigenvectors  
    [A,ets]=eig(M);
    ets=diag(ets);
    [ets,index]=sort(ets);
    A=A(:,index);

    % Normalization
    r=2*(0:N-1)+1;
    if normalization==0;
       N2=sum(A(:,n).^2);
       NS=sign(sum(r.*transpose(A(:,n))));
       A=A/sqrt(N2)*NS;
    else
       mv=(1:2:p).';
       N2=sqrt(sum( ( sqrt(gamma((p+mv)/2+1).*gamma((p-mv)/2+1) ).*A(:,n)).^2 ));
       NS=sign(sum(r.*A(:,n)'));
       A=A/N2*NS;
    end

    % Ince Polynomial
    [R,X]=meshgrid(r,z);
    IP=sin(X.*R)*A(:,n);
    eta=ets(n);

end

IP=reshape(IP,[largo,ancho]);  % reshape output to original format

end
