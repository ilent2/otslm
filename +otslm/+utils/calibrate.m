function lookuptable = calibrate(slm, cam, varargin)
% CALIBRATE method to calibrate phase-only SLM
%
% lookuptable = calibrate(slm, cam, ...) attempts to calibrate the
% showable device (slm) imaged using the viewable device (cam).
% The default method assumes the camera is in the Fourier plane of
% the SLM.
%
% Optional named parameters:
%
%   'method'      method    Method to use for calibration
%   'methodargs'  {args}    Method specific arguments
%   'resolution'  res       Number of values between [0, 1) in lookup table.
%   'tabletype'   type      Specifies the type of lookup table to generate.
%
% Supported methods:
%
%   'checker'         Minimise the zero-th order by changing the phase
%       of the values in a checkerboard.
%
%   'michaelson'      Michaelson interferometer image of SLM surface.
%       Change in intensity of image determines phase change.
%
%   'smichaelson'     Sloped Michaelson interferometer with fringes.
%       Changes half the SLM phase which shifts the fringes on half
%       of the device.
%
%   'step'            Applies a step function and looks at the minima.
%   'pinholes'        Applies pinholes with different phase.
%   'linear'          Attempt to optimise diffraction from linear grating.
%
% Supported table types (may not be supported by all methods):
%
%   'single'            Single lookup table for entire device.
%   'pixel'             Lookup table for each slm device pixel.
%   {'regions', [X,Y]}  Lookup table for each XxY region of device.

p = inputParser;
p.addParameter('method', 'checker');
p.addParameter('methodargs', {});
p.addParameter('resolution', 256);
p.addParameter('tabletype', 'single');
p.parse(varargin{:});

error('Not yet implemented');

