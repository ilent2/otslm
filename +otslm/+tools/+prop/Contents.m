% OTSLM/TOOLS/PROP Package containing propogation algorithms
%
% Classes
%   Fft3Forward     - Propagate using forward 3-D fast Fourier transform
%   Fft3Inverse     - Propagate using inverse 3-D fast Fourier transform
%   FftEwaldForward - Propagate using forward Ewald sphere and 3-D FFT
%   FftEwaldInverse - Propagate using inverse Ewald sphere and 3-D FFT
%   FftForward      - Propagate using forward 2-D fast Fourier transform
%   FftInverse      - Propagate using inverse 2-D fast Fourier transform
%   FftDebyeForward - Propagate using forward 2-D FFT formulation of Debye integral.
%   Ott2Forward     - Propagate the field using the optical tweezers toolbox.
%   OttForward      - Propagate the field using the optical tweezers toolbox
%   RsForward       - Propagate the field forward using Rayleight-Sommerfeld integral
%
% Base classes
%   Propagator      - Base class for field propagation methods
%   FftBase         - Abstract base class for Fft* propagator methods
%   EwaldBase       - Abstract base class for *Ewald* propagator methods
%   Fft3Base        - Abstract base class for Fft3* propagator methods
%
% Other files
%   vis_rsmethod.cpp - MEX file for RsForward
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.
