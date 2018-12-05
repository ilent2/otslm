function lt = linear(slm, cam, varargin)
% LINEAR attempt to optimise diffraction from a linear grating
%
% This method does not produce a good estimate of the lookup table
% but is useful for generating a lookup table to maximise deflection
% into a particular direction or region.
%
% This method is experimental.
%
% lt = linear(slm, cam, ...)
%
% Optional named arguments:
%   grating         str   type of grating to display on the device
%   max_iterations  num   maximum number of iterations to run
%   show_progrerss  bool  show progress of the method
%   method          str   method to use for optimisation
%   dof             num   number of degrees of freedom
%   spacing         num   diffraction grating spacing
%   initial_cond    str   initial condition

  % TODO: Add an option to minimise voltage difference (value distance)

  % Parse method arguments
  p = inputParser;
  p.addParameter('grating', 'sinusoid');
  p.addParameter('max_iterations', 10000);
  p.addParameter('show_progress', true);
  p.addParameter('method', 'polynomial');
  p.addParameter('dof', 10);
  p.addParameter('spacing', 10);
  p.addParameter('initial_cond', 'rand');
  p.addParameter('location', []);
  p.parse(varargin{:});

  % Get the full range of values we can use
  fullTable = slm.linearValueRange('structured', true);

  % Generate linear grating with this phase mapping
  switch p.Results.grating
    case 'linear'
      grating = otslm.simple.linear(slm.size, p.Results.spacing);
      patterndof = p.Results.spacing;
    case 'sinusoid'
      grating = otslm.simple.sinusoid(slm.size, p.Results.spacing, 'type', '1d');
      patterndof = p.Results.spacing/2;
    otherwise
      error('Unknown grating type');
  end
  
  % Check degrees of freedom
  if p.Results.dof > patterndof
    warning('otslm:utils:calibrate:linear:methoddof', ...
      'More degrees of freedom than grating colour levels');
  end
  
  % Generate normalized table for phase
  nphase = linspace(0, 1, p.Results.dof);
  
  % Generate initial guess and normalized lookup table
  switch p.Results.method
    case 'polynomial'
      
      % Check for polynomial overfitting
      if p.Results.dof > patterndof/2
        warning('otslm:utils:calibrate:linear:methoddofpoly', ...
          'Higher order polynomail may lead to overfitting');
      end
      
      if ischar(p.Results.initial_cond)
        switch p.Results.initial_cond
          case 'rand'
            coeffs = randn(p.Results.dof, 1);
          case 'linear'
            coeffs = zeros(p.Results.dof, 1);
            if p.Results.dof >= 2
              coeffs(2) = 1.0;
            end
          otherwise
            error('Unknown initial condition parameter value');
        end
      else
        % TODO: We could also do a polyfit if the initial condition
        % is the initial phase guess instead?
        coeffs = p.Results.initial_cond;
        assert(length(coeffs) == p.Results.dof, ...
            'not enough initial conditions');
      end
      
      nvalueTable = polyval(coeffs, nphase);
      stepsize = 0.01;
      has_derivative = false;
      
    case 'stepped'
      
      if ischar(p.Results.initial_cond)
        switch p.Results.initial_cond
          case 'rand'
            nvalueTable = rand(size(nphase));
          case 'linear'
            nvalueTable = nphase;
          otherwise
            error('Unknown initial condition parameter value');
        end
      else
        nvalueTable = p.Results.initial_cond;
        assert(length(nvalueTable) == p.Results.dof, ...
            'not enough initial conditions');
      end
      
      scale = 0.01;
      
    otherwise
      error('Unknown method parameter in calibrage/method_linear');
  end
  
  % Evaluate initial guess
  goodness = method_linear_check(slm, cam, nvalueTable, ...
      fullTable, nphase, grating, p.Results.location);
  bestgoodness = goodness(1);
  
  % Create a figure to track the progress
  if p.Results.show_progress
    hf = figure();
    h = axes(hf);
    plt = plot(h, 1, goodness(1));
    xlabel(h, 'Attempts');
    ylabel(h, 'Intensity');
    title(h, 'Intensity in first order');
    btn = uicontrol(hf, 'Style', 'pushbutton', 'String', 'Stop',...
        'Position', [20 20 50 20]);  
    btn.Enable = 'Inactive';
    btn.UserData = true;
    btn.ButtonDownFcn = @(src, event) set(btn, 'UserData', false);
    drawnow;
    
    figure_active = @() ishandle(hf) && btn.UserData;
  else
    figure_active = @() true;
  end

  % Loop for some number of trials
  ii = 1;
  while figure_active() && ii < p.Results.max_iterations
    
    % Increment ii
    ii = ii + 1;
    
    % Attempt to optimise the pattern
    switch p.Results.method
      case 'polynomial'
        
        if has_derivative
          deriv = (goodness(ii-1) - goodness(ii-2))/stepsize;
          newCoeffs(index) = newCoeffs(index) - goodness(ii-1)/deriv;
          
          has_derivative = false;
        else
          index = randi([1, length(coeffs)], 1);
          newCoeffs = coeffs;
          newCoeffs(index) = newCoeffs(index) + stepsize;
          has_derivative = true;
        end
        
        % Calculate new normalize value table from coefficients
        nNewValueTable = polyval(newCoeffs, nphase);
        
      case 'stepped'
        nNewValueTable = nvalueTable + scale*randn(size(nvalueTable));

      otherwise
        error('Unknown method parameter in calibrage/method_linear');
    end
    
    % Check the new pattern
    goodness(ii) = method_linear_check(slm, cam, nNewValueTable, ...
        fullTable, nphase, grating, p.Results.location);
    
    % Reject or keep the pattern
    switch p.Results.method
      case 'polynomial'
        % If the shift improved the result, keep it
        if goodness(ii) > bestgoodness
          bestgoodness = goodness(ii);
          nvalueTable = nNewValueTable;
          coeffs = newCoeffs;
        end
        
      case 'stepped'
        % If the shift improved the result, keep it
        if goodness(ii) > bestgoodness
          bestgoodness = goodness(ii);
          nvalueTable = nNewValueTable;
        end

      otherwise
        error('Unknown method parameter in calibrage/method_linear');
    end
    
    % Plot the progress
    if p.Results.show_progress
      plt.XData = 1:ii;
      plt.YData = goodness;
      drawnow;
    end

  end
  
  % Get the output value table
  valueTable = method_linear_valuetable(nvalueTable, fullTable);

  % Package the result
  lt =  otslm.utils.LookupTable(2*pi*nphase.', valueTable.');

end

function [valueTable, idx] = method_linear_valuetable(nvalueTable, fullTable)

  idx = mod(nvalueTable, 1);
  idx(idx < 0) = idx(idx < 0) + 1;
  idx = round(idx*(length(fullTable)-1))+1;
  
  % Convert from index to values
  valueTable = fullTable(:, idx);

end

function val = method_linear_check(slm, cam, nvalueTable, fullTable, ...
    nphase, grating, location)
  
  if ~isfinite(nvalueTable)
    val = 0;
    return;
  end

  % Convert the new pattern to a raw pattern
  valueTable = method_linear_valuetable(nvalueTable, fullTable);
  rawpattern = otslm.tools.finalize(grating, ...
      'colormap', {nphase.', valueTable.'});

  % Check the new pattern
  slm.showRaw(rawpattern);
  im = cam.viewTarget();
  
  % Calculate the intensity in the ROI
  if isempty(location)
    val = sum(im(:));
  elseif numel(location) == 2
    val = im(location(1), location(2));
  elseif numel(location) == 4
    val = im(location(1):location(3), location(2):location(4));
    val = sum(val(:));
  else
    val = im(location);
    val = sum(val(:));
  end
end

