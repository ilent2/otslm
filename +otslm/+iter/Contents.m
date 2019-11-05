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
% Base classes
%   IterBase           - Base class for iterative algorithm classes.
%   IterCombine        - Base class for iterative combination algorithms.
%   IterBaseEwald      - Abstract base class for 3-D Ewald iterative algorithm classes
%
% Files
%   GerchbergSaxton    - Implementation of Gerchberg-Saxton and Adaptive-Adaptive algorithms
%   CombineGerchbergSaxton - Implementation of Gerchberg-Saxton type combination algorithms.
%   DirectSearch       - Optimiser to search through each pixel value to optimise hologram
%   SimulatedAnnealing - Optimise the pattern using simulated annealing.
%   GerchbergSaxton3d  - Implementation of 3-D Gerchberg-Saxton and Adaptive-Adaptive algorithms
%   bsc                - Optimisation in vector spherical wave function basis
%   bowman2017         - Wrapper for Bowman 2017 conjugate gradient implementation
%
% Sub-packages
%   +objectives        - objective functions for use with optimisation algorithms
%
% Private sub-folders
%   bowman2017py       - Files used by Bowman2017
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.
