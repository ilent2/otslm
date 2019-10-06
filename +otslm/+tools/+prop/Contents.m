% OTSLM/TOOLS/PROP Package containing propogation algorithms
%
% Classes
%   Fft3Forward     - Propogate using forward 3-D fast fourier transform
%   Fft3Inverse     - Propogate using inverse 3-D fast fourier transform
%   FftEwaldForward - Propogate using forward Ewald sphere and 3-D FFT
%   FftEwaldInverse - Propogate using inverse Ewald sphere and 3-D FFT
%   FftForward      - Propogate using forward 2-D fast fourier transform
%   FftInverse      - Propogate using inverse 2-D fast fourier transform
%   Ott2Forward     - OTTFORWARD Propagate the field using the optical tweezers toolbox
%   OttForward      - Propagate the field using the optical tweezers toolbox
%   RsForward       - Propagate the field forward using Rayleight-Sommerfeld integral
%
% Base classes
%   Propagator      - Base class for field propagation methods
%   FftBase         - Abstract base class for Fft* propagator methods
%   EwaldBase       - Abstract base class for *Ewald* propagator methods
%   Fft3Base        - FFTBASE Abstract base class for Fft3* propagator methods
%
% Other files
%   vis_rsmethod.cpp - MEX file for RsForward
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.
