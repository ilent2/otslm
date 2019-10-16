classdef IterBase < handle
% Base class for iterative algorithm classes
% Inherits from :class:`handle`.
%
% Methods
%   - run()      -- Run the iterative method
%
% Properties
%   - guess      -- Best guess at hologram pattern (complex)
%   - target     -- Target pattern the method tries to approximate (complex)
%   - vismethod  -- Method used to do the visualisation
%   - invmethod  -- Method used to calculate initial guess/inverse-visualisation
%
%   - phase      -- Phase of the best guess (real: 0, 2*pi)
%   - amplitude  -- Amplitude of the best guess (real)
%
%   - objective  -- Objective function used to evaluate fitness or []
%   - fitness    -- Fitness evaluated after every iteration or []
%
% Abstract methods:
%   - iteration()  --   run a single iteration of the method

% Copyright 2018 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties
    guess       % Best guess at hologram pattern
    target      % Target pattern the method tries to approximate
    vismethod   % Method used to do the visualisation
    invmethod   % Method used to calculate initial guess/inverse-visualisation
    
    % Objective function used to evaluate fitness
    % This may not be required by all methods but can still be
    % provided for diagnostics.
    objective
    
    % Fitness evaluated after every iteration
    % Empty if objective function is not provided.
    fitness     
  end
  
  properties (Dependent)
    phase         % Phase of the best guess (real: 0, 2*pi)
    amplitude     % Amplitude of the best guess (real)
  end

  properties (Hidden)
    fitnessPlot % Handle to the fitness plot
    running     % True when the method is running
  end

  methods (Abstract)
    result = iteration(mtd)    % Run a single iteration of the method
  end

  methods
    function mtd = IterBase(varargin)
      % Abstract constructor for iterative algorithm base class
      %
      % mtd = IterBase(target, ...)
      %
      % Optional named arguments:
      %   guess     im     Initial guess at complex amplitude pattern.
      %     If not image is supplied, a guess is created using invmethod.
      %
      %   vismethod fcn    Function to calculate far-field.  Takes one
      %     argument: the complex amplitude near-field.
      %     Default: @otslm.tools.prop.FftForward.simpleProp.evaluate
      %
      %   invmethod fcn    Function to calculate near-field.  Takes one
      %     argument: the complex amplitude far-field.
      %     Default: @otslm.tools.prop.FftInverse.simpleProp.evaluate
      %
      %   objective fcn    Objective function to measure fitness.
      %     Default: @otslm.iter.objectives.FlatIntensity

      % Parse inputs
      p = inputParser;
      p.addRequired('target');
      p.addParameter('guess', []);
      p.addParameter('vismethod', []);
      p.addParameter('invmethod', []);
      p.addParameter('objective', otslm.iter.objectives.FlatIntensity());
      p.addParameter('gpuArray', []);
      p.parse(varargin{:});

      % Store inputs
      mtd.target = double(p.Results.target);
      mtd.guess = p.Results.guess;
      mtd.vismethod = p.Results.vismethod;
      mtd.invmethod = p.Results.invmethod;
      mtd.objective = p.Results.objective;
      
      % Handle default gpuArray argument
      useGpuArray = p.Results.gpuArray;
      if isempty(useGpuArray)
        useGpuArray = isa(mtd.target, 'gpuArray') || isa(mtd.guess, 'gpuArray');
      end
      
      % Handle default visualisation and inverse methods
      if isempty(mtd.vismethod)
        prop = otslm.tools.prop.FftForward.simpleProp(mtd.target, ...
            'gpuArray', useGpuArray);
        mtd.vismethod = @prop.propagate;
      end
      if isempty(mtd.invmethod)
        prop = otslm.tools.prop.FftInverse.simpleProp(mtd.target, ...
            'gpuArray', useGpuArray);
        mtd.invmethod = @prop.propagate;
      end
      
      % Ensure guess and target are gpuArrays
      if useGpuArray
        mtd.target = gpuArray(mtd.target);
        mtd.guess = gpuArray(mtd.guess);
      end

      % Handle default argument for guess
      if isempty(mtd.guess)
        mtd.guess = mtd.invmethod(mtd.target);
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
          mtd.showFitness('show_stop_button', true);
				end
      end

      % Change the method state to stopped
      mtd.running = false;

      % Return the latest guess
      if nargout > 0
        result = mtd.guess;
      end
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
        data = mtd.fitness;
        if isempty(data)
          data = NaN;
        end
				mtd.fitnessPlot = plot(ax, 1:length(data), data);
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
      if ~isempty(mtd.fitness)
        mtd.fitnessPlot.XData = 1:length(mtd.fitness);
        mtd.fitnessPlot.YData = mtd.fitness;
        drawnow;
      end
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
      % Guess should be a complex amplitude.
      
      % Check we have an objective
      if isempty(mtd.objective)
        error('Can not evaluate fitness without objective function');
      end

      p = inputParser;
      p.addOptional('guess', mtd.guess);
      p.parse(varargin{:});

      % Evaluate guess
      trial = mtd.vismethod(p.Results.guess);

      % Evaluate the score or multiple scores
      if size(mtd.target, 3) ~= size(trial, 3)
        score = zeros(1, size(mtd.target, 3));
        for ii = 1:length(score)
          our_score = mtd.objective.evaluate(trial(:, :, ii), mtd.target);
        
          % Collect result from gpu
          if isa(our_score, 'gpuArray')
            our_score = gather(our_score);
          end
          
          score(ii) = our_score;
        end
      else
        score = mtd.objective.evaluate(trial, mtd.target);
        
        % Collect result from gpu
        if isa(score, 'gpuArray')
          score = gather(score);
        end
      end
    end
    
    function set.objective(obj, val)
      % Check objective type
      assert(isempty(val) || isa(val, 'otslm.iter.objectives.Objective'), ...
        'Objective must be [] or an otslm.iter.objectives.Objective');
      obj.objective = val;
    end
    
    function val = get.phase(obj)
      % Get the guess phase
      val = angle(obj.guess);
    end
    
    function val = get.amplitude(obj)
      % Get the guess amplitude
      val = abs(obj.guess);
    end
  end
end
