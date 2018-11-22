classdef IterBase < handle
% ITERBASE base class for iterative algorithm classes
%
% Properties:
%   guess         Best guess at hologram pattern
%   target        Target pattern the method tries to approximate
%   vismethod     Method used to do the visualisation
%   invmethod     Method used to calculate initial guess/inverse-visualisation
%   visdata       Additional arguments to pass to vismethod
%   invdata       Additional arguments to pass to invmethod
%   objective     Objective function used to evaluate fitness
%   fitness       Fitness evaluated after every iteration
%
% Abstract methods:
%   iteration()       run a single iteration of the method
%
% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties
    guess       % Best guess at hologram pattern
    target      % Target pattern the method tries to approximate
    vismethod   % Method used to do the visualisation
    invmethod   % Method used to calculate initial guess/inverse-visualisation
    visdata     % Additional arguments to pass to vismethod
    invdata     % Additional arguments to pass to invmethod
    objective   % Objective function used to evaluate fitness
    fitness     % Fitness evaluated after every iteration
  end

  properties (Hidden)
    fitnessPlot % Handle to the fitness plot
    running     % True when the method is running
  end

  methods (Abstract)
    result = iteration(mtd)    % Run a single iteration of the method
  end

  methods (Static)
    function output = defaultVisMethod(input, varargin)
      % Calculate the far-field of the device from the near-field

      p = inputParser;
      p.addParameter('incident', []);
      p.parse(varargin{:});
      
      if isreal(input)
        error('input must be complex');
      end
      
      output = otslm.tools.visualise(input, ...
          'incident', p.Results.incident, ...
          'padding', size(input)/2, 'trim_padding', true, ...
          'method', 'fft');

%       incident = p.Results.incident;
%       if isempty(incident)
%         incident = ones(size(input));
%       end
% 
%       output = fftshift(fft2(incident .* input))./numel(input);
    end

    function output = defaultInvMethod(input, varargin)
      % Calculate the near-field of the device from the far-field
      output = ifft2(fftshift(input));
    end
  end

  methods
    function mtd = IterBase(varargin)
      % Abstract constructor for iterative algorithm base class
      %
      % mtd = IterBase(target, ...)
      %
      % Optional named arguments:
      %   guess     im     Initial guess at phase pattern.
      %     Image must be complex amplitude or real phase in range 0 to 2*pi.
      %     If not image is supplied, a guess is created using invmethod.
      %   vismethod fcn    Function to calculate far-field.  Takes one
      %     argument: the complex amplitude near-field.
      %   invmethod fcn    Function to calculate near-field.  Takes one
      %     argument: the complex amplitude far-field.
      %   visdata   {}     Cell array of data to pass to vis function
      %   invdata   {}     Cell array of data to pass to inv function
      %   objective fcn    Objective function to measure fitness.

      % Parse inputs
      p = inputParser;
      p.addRequired('target');
      p.addParameter('guess', []);
      p.addParameter('vismethod', @otslm.iter.IterBase.defaultVisMethod);
      p.addParameter('invmethod', @otslm.iter.IterBase.defaultInvMethod);
      p.addParameter('visdata', {});
      p.addParameter('invdata', {});
      p.addParameter('objective', @otslm.iter.objectives.flatintensity);
      p.parse(varargin{:});

      % Store inputs
      mtd.target = double(p.Results.target);
      mtd.guess = p.Results.guess;
      mtd.vismethod = p.Results.vismethod;
      mtd.invmethod = p.Results.invmethod;
      mtd.visdata = p.Results.visdata;
      mtd.invdata = p.Results.invdata;
      mtd.objective = p.Results.objective;

      % Handle default argument for guess
      if isempty(mtd.guess)
        mtd.guess = mtd.invmethod(mtd.target);
      end

      % If the guess is not real, convert from complex amplitude to phase
      if ~isreal(mtd.guess)
        mtd.guess = angle(mtd.guess);
      end
    end

    function result = run(mtd, num_iterations, varargin)
      % Run the method for a specified number of iterations
      %
      % result = mtd.run(num_iterations, ...) run for the specified
      % number of iterations.
      %
      % Optional named arguments:
      %   show_progress   bool    display a figure with optimisation progress

      % Parse optional inputs
      p = inputParser;
      p.addParameter('show_progress', true);
      p.parse(varargin{:});

      % Setup the progress figure with the stop button
			if p.Results.show_progress
        mtd.showFitness('show_stop_button', true);
      end

      % Change the method state to running
      mtd.running = true;

			% Run for num_iterations updating the guess
      ii = 0;
      while mtd.running && ii < num_iterations

        % Advance the iteration count
        ii = ii + 1;

        % Do an iteration
        mtd.iteration();

				% Report the current fitness
				if p.Results.show_progress
          mtd.showFitness();
				end
      end

      % Change the method state to stopped
      mtd.running = false;

      % Return the latest guess
      result = mtd.guess;
    end

    function showFitness(mtd, varargin)
      % Show a graph displaying the fitness of the hologram
      %
      % mtd.showFitness() shows the fitness for each iteration.
      %
      % Optional named arguments:
      %   axes    ax     The axes object to put the plot in
      %   show_stop_button bool  If the stop button should be shown

      p = inputParser;
      p.addParameter('show_stop_button', false);
      p.addParameter('axes', []);
      p.parse(varargin{:});

			% Setup the figure for progress
      if isempty(mtd.fitnessPlot) || ~ishandle(mtd.fitnessPlot)

        ax = p.Results.axes;
        if isempty(ax)
          % If no axes supplied, create one
          hf = figure();
          ax = axes(hf);
        else
          % Otherwise get the parent for placing the button
          hf = ax.Parent;
        end

        % Setup the plot
				mtd.fitnessPlot = plot(ax, 1:length(mtd.fitness), mtd.fitness);
				xlabel(ax, 'Iteration');
				ylabel(ax, 'Fitness');
				title(ax, 'Iterative method progress');
        set(ax, 'YScale', 'log');
        drawnow;

				% Create a stop button
        if p.Results.show_stop_button
          btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Stop',...
              'Position', [ax.Position(1:2) 50 20]);
          btn.Enable = 'Inactive';
          btn.ButtonDownFcn = @mtd.stopIterations;
        end
      end

      % Update the content of the figure
      mtd.fitnessPlot.XData = 1:length(mtd.fitness);
      mtd.fitnessPlot.YData = mtd.fitness;
      drawnow;
    end

    function stopIterations(mtd, src, event)
      % Callback for the stop button in showFitness
      mtd.running = false;
    end

    function score = evaluateFitness(mtd, varargin)
      % Evaluate the fitness of the current guess
      %
      % score = mtd.evaluateFitness() visualises the current guess and
      % evaluate the fitness.
      %
      % score = mtd.evaluateFitness(guess) evaluate the fitness of the
      % given guess.  If guess is a stack of matrices, the returned
      % score is a vector with size(trial, 3) elements.

      p = inputParser;
      p.addOptional('guess', mtd.guess);
      p.parse(varargin{:});

      % Evaluate guess
      trial = mtd.vismethod(exp(1i*p.Results.guess), mtd.visdata{:});

      % Evaluate the score or multiple scores
      if size(mtd.target, 3) ~= size(trial, 3)
        score = zeros(1, size(mtd.target, 3));
        for ii = 1:length(score)
          score(ii) = mtd.objective(mtd.target, trial(:, :, ii));
        end
      else
        score = mtd.objective(mtd.target, trial);
      end
    end
  end
end
