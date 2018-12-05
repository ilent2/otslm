% +OTSLM/+ITER iterative algorithms for pattern generation.
%
% This sub-package contains implementations of algorithms for optimising
% SLM patterns to generate a particular target light distribution.
%
% The easiest to use are gs and bowman2017.  These two methods produce
% decent results.  direct_search and simulated_annealing can be used to
% further optimise a initial guess at a SLM pattern but can be slow if
% starting with a bad initial guess.  bsc is a work in progress.
%
% Files
%   GerchbergSaxton    - Implementation of Gerchberg-Saxton and Adaptive-Adaptive algorithms
%   DirectSearch       - search through each pixel value to optimise hologram
%   IterBase           - base class for iterative algorithm classes
%   SimulatedAnnealing - Optimise the pattern using simulated annealing
%   GerchbergSaxton3d  - Implementation of 3-D Gerchberg-Saxton and Adaptive-Adaptive algorithms
%   IterBase3d         - base class for 3-D iterative algorithm classes
%   bsc                - optimisation in vector spherical wave function basis
%   bowman2017         - wrapper for Bowman 2017 conjugate gradient implementation
%
% Sub-packages
%   +objectives        - objective functions for use with optimisation algorithms
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.
