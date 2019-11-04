% +OTSLM/+TOOLS tools for working with and combining patterns
%
% Files
%   combine         - Combines multiple patterns
%   dither          - Creates a binary pattern from gray-scale image.
%   encode1d        - Encode the target pattern amplitude into the phase pattern size
%   finalize        - Finalize a pattern, applying a color map and taking the modulo.
%   hologram2volume - Generate 3-D volume representation from hologram.
%   mask_regions    - Adds patterns to base using masking
%   sample_region   - Generates a pattern for sampling regions on SLM.
%   spatial_filter  - Applies a spatial filter to the image spectrum.
%   visualise       - Generates far-field plane images of the phase pattern
%   bsc2hologram    - Calculates the far-field hologram for a BSC beam
%   colormap        - Applies a colormap to a pattern.
%   hologram2bsc    - Convert 2-D paraxial pattern to beam shape coefficients
%   phaseblur       - Simulate pixel phase blurring
%   volume2hologram - Generate hologram from 3-D volume by un-mapping the Ewald sphere
%   castValue       - Convert from logical pattern to specified value range
%   lensesAndPrisms - Generates a hologram using the Lenses and Prisms algorithm
%   make_beam       - Combine the phase, amplitude and incident patterns.
%
% Subpackages
%   +prop           - propogation methods (used by visualise and iter)
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.
