classdef PrismsAndLenses < otslm.utils.RedTweezers.RedTweezers
% Prisms and Lenses algorithm for RedTweezers.
% Inherits from :class:`RedTweezers`.
%
% Implements the Prisms and Lenses algorithm in an OpenGl shader.
%
% See also PrismsAndLenses and :class:`Showable`.

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

  properties (SetObservable)
    
    % Array of PrismsAndLenses spots
    spots otslm.utils.RedTweezers.PrismsAndLensesSpot
    
    total_intensity % Total intensity parameter used for intensity shaping
    centre          % Centre of the hologram as a function of its size
    size            % Size of the hologram (in microns)
    focal_length    % Focal length (in microns)
    wavenumber      % Wavenumber (inverse microns)
    blazing         % Blazing table for colourmap (32 numbers)
    zernike         % Zernike coefficients (12 numbers)
    
    % (bool) True if the texture should always be used to represent
    % the array of spots.  This defaults to numel(spots) > 50 unless
    % explicitly set.
    use_texture
  end
  
  properties (SetAccess=protected)
    shader_text   % Contents of the GLSL file before substitution
  end
  
  properties (Constant)
    glsl_filename = 'PrismsAndLenses.glsl';   % Filename for GLSL source
  end
  
  methods
    function rt = PrismsAndLenses(varargin)
      % Connects to RedTweezers and loads the Prisms and Lenses shader
      %
      % rt = RedTweezers() connect to a running instance of RedTweezers.
      % Default address is 127.0.0.1 port 61556.
      %
      % rt = RedTweezers(address, port) specifies a custom address/port.
      
      ip = inputParser();
      ip.addOptional('address', '127.0.0.1');
      ip.addOptional('port', 61557);
      ip.parse(varargin{:});
      
      % Call base class constructor
      rt = rt@otslm.utils.RedTweezers.RedTweezers(...
        ip.Results.address, ip.Results.port);
      
      % Generate the file path for the GLSL file
      our_filename = mfilename('fullpath');
      [our_path, ~, ~] = fileparts(our_filename);
      glsl_fullpath = [our_path, filesep, rt.glsl_filename];
      
      % Load the GLSL file
      rt.shader_text = rt.readGlslFile(glsl_fullpath);
      
      % Add callbacks for set methods
      addlistener(rt, 'spots', 'PostSet', @rt.handleSetEvents);
      addlistener(rt, 'total_intensity', 'PostSet', @rt.handleSetEvents);
      addlistener(rt, 'centre', 'PostSet', @rt.handleSetEvents);
      addlistener(rt, 'size', 'PostSet', @rt.handleSetEvents);
      addlistener(rt, 'focal_length', 'PostSet', @rt.handleSetEvents);
      addlistener(rt, 'wavenumber', 'PostSet', @rt.handleSetEvents);
      addlistener(rt, 'blazing', 'PostSet', @rt.handleSetEvents);
      addlistener(rt, 'zernike', 'PostSet', @rt.handleSetEvents);
      addlistener(rt, 'use_texture', 'PostSet', @rt.handleSetEvents);
      
      % Send the shader so the device is ready for other paramters
      rt.sendShader();
    end
    
    function varargout = updateAll(rt, send)
      % Resends all information to RedTweezers
      %
      % Only sends set options (leaves others at RedTweezers defaults)
      % Does not send the shader.
      %
      % If send is false, the command isn't sent.  Default value for
      % send is nargout == 0
      
      % Handle default send argument
      if nargin < 2
        send = nargout == 0;
      end
      
      % Get base commands
      cmds = updateAll@otslm.utils.RedTweezers.RedTweezers(rt, false);
      
      % This seems to break things
      %cmds = [cmds, rt.sendShader(false)];
      
      if ~isempty(rt.spots)
        cmds = [cmds, rt.sendUniform(0, numel(rt.spots), false)];
        cmds = [cmds, rt.sendSpots(false)];  % 2
      end
      
      if ~isempty(rt.total_intensity)
        cmds = [cmds, rt.sendUniform(1, rt.total_intensity, false)];
      end
      
      if ~isempty(rt.centre)
        cmds = [cmds, rt.sendUniform(3, rt.centre, false)];
      end
      
      if ~isempty(rt.size)
        cmds = [cmds, rt.sendUniform(4, rt.size, false)];
      end
      
      if ~isempty(rt.focal_length)
        cmds = [cmds, rt.sendUniform(5, rt.focal_length, false)];
      end
      
      if ~isempty(rt.wavenumber)
        cmds = [cmds, rt.sendUniform(6, rt.wavenumber, false)];
      end
      
      if ~isempty(rt.blazing)
        cmds = [cmds, rt.sendUniform(7, rt.blazing, false)];
      end
      
      if ~isempty(rt.zernike)
        cmds = [cmds, rt.sendUniform(8, rt.zernike, false)];
      end
      
      % Send commands
      if send
        rt.sendCommand(cmds);
      end
      
      % Write outputs
      if nargout
        varargout{1} = cmds;
      end
    end
    
    function addSpot(rt, varargin)
      % Add a spot to the pattern
      %
      % rt.addSpot(position, ...) declares a new spot at
      % the specified position [x, y, z].  Uses :class:`PrismsAndLensesSpot`
      % to represent the spot.
      %
      % Optional named parameters:
      %   - 'oam'    int   -- Vortex charge
      %   - 'phase'  float -- Phase offset for the spot
      %   - 'intensity' float -- Intensity for the spot
      %   - 'aperture'  [x, y, R] -- Position and radius of aperture
      %   - 'line'   [x, y, z, phase] -- Direction, length and phase of line

      % Create a spot
      spot = otslm.utils.RedTweezers.PrismsAndLensesSpot(varargin{:});

      % Add it to the array
      rt.spots = [rt.spots; spot];
    end

    function removeSpot(rt, index)
      % Remove the specified spot from the pattern
      %
      % rt.removeSpot() removes a spot from the end of the array.
      %
      % Can also directly modify the Spot array

      % Handle default spot (last spot)
      if nargin < 2
        index = numel(rt.spots);
      end
      
      if islogical(index)
        assert(numel(index) == numel(rt.spots), ...
          'Number of logical indices must match number of spots');
      else
        assert(all(index > 0 & index <= numel(rt.spots)), ...
          'Numeric indices must be between 1 and numel(spots)');
      end
      
      rt.spots(index) = [];
    end
    
    function set.spots(rt, value)
      % Update the spots array
      
      assert(all(isa(value, 'otslm.utils.RedTweezers.PrismsAndLensesSpot')), ...
        'value must be an array of spots');
      
      rt.spots = value(:);
    end
    
    function set.use_texture(rt, value)
      % Set the use_texture boolean
      
      assert(islogical(value) || isempty(value), ...
        'value must be logical or empty');
      
      rt.use_texture = value;
    end
    
    function set.total_intensity(rt, value)
      % Update the total intensity and send to the device
      
      assert(isnumeric(value) && isscalar(value), ...
        'Value must be numeric and scalar');
      
      rt.total_intensity = value;
    end
    
    function set.centre(rt, value)
      % Set the centre location of the pattern
      
      assert(numel(value) == 2, 'value must be 2 element vector');
      assert(isnumeric(value), 'value must be a pair of numbers');
      assert(all(value <= 1 & value >= 0), 'value must be between 0 and 1');
      
      rt.centre = value;
    end
    
    function set.size(rt, value)
      % Set the size of the hologram (in microns)
      
      assert(numel(value) == 2, 'value must be 2 element vector');
      assert(isnumeric(value), 'value must be a pair of numbers');
      
      rt.size = value;
    end
    
    function set.focal_length(rt, value)
      % Set the focal length (in microns)
      
      assert(isnumeric(value) && isscalar(value), 'value must be numeric scalar');
      
      rt.focal_length = value;
    end
    
    function set.wavenumber(rt, value)
      % Set the wavenumber (inverse microns)
      
      assert(isnumeric(value) && isscalar(value), 'value must be numeric scalar');
      
      rt.wavenumber = value;
    end
    
    function set.blazing(rt, value)
      % Set the blazing (lookup) table (must be 32 numbers)
      
      assert(numel(value) == 32, 'value must be a 32 element vector');
      assert(isnumeric(value), 'value must be numeric');
      assert(all(value <= 1 & value >= 0), 'values must be between 0 and 1');
      
      rt.blazing = value;
    end
    
    function set.zernike(rt, value)
      % Set the zernike coefficients for aberation correction (12 numbers)
      
      assert(numel(value) == 12, 'value must be a 32 element vector');
      assert(isnumeric(value), 'value must be numeric');
      
      rt.zernike = value;
    end
    
    function varargout = sendShader(rt, send)
      % Send shader to the device
      %
      % rt.sendShader(send) sends the text string to the device.
      %
      % If send is false, the command isn't sent.  Default value for
      % send is nargout == 0
      
      % Default send value
      if nargin < 2
        send = nargout == 0;
      end
      
      % Get the shader text
      shader = rt.shader_text;
      
      % Determine data type strings based on number of spots
      if numel(rt.spots) > 50 || (~isempty(rt.use_texture) && rt.use_texture)
        spotsdecl = 'sampler2D spots';
        spotsret = 'texture(spots, vec2( (float(j) +0.5) / 4.0, ( float(i) + 0.5) / float(n) ))*500.0 -250.0';
      else
        spotsdecl = 'vec4 spots[200]';
        spotsret = 'spots[4*i +j]';
      end
      
      % Insert strings for the spot declarations
      shader = strrep(shader, '%%spotsdecl%%', spotsdecl);
      shader = strrep(shader, '%%spotsret%%', spotsret);
      
      % Send the shader
      [varargout{1:nargout}] = ...
        sendShader@otslm.utils.RedTweezers.RedTweezers(rt, shader, send);
    end
  end
  
  methods (Hidden)
    
    function varargout = sendSpots(rt, send)
      % Send the spots array
      
      if nargin < 2
        send = nargout == 0;
      end
      
      % Then send the data, from the GLSL source code:
      % spot parameters- each spot corresponds to 4 vec4, first one is x,y,z,l, second one is amplitude, -,-,-
      % element 0 x  y  z  l    (x,y,z in um and l is an integer)
      % element 1 intensity (I) phase -  -
      % element 2 na.x na.y na.r -  (the x, y position, and radius, of the spot on the SLM- useful for Shack-Hartmann holograms)
      % element 3 line trapping x y z and phase gradient.  xyz define the size and angle of the line, phase gradient (between +/-1) is the
      % scattering force component along the line.  Zero is usually a good choice for in-plane line traps
      
      % Check there is work to do
      if numel(rt.spots) == 0
        if nargout > 0
          varargout{1} = '';
        end
        return;
      end
      
      data = [rt.spots.position; rt.spots.oam];
      data(:, :, 2) = [rt.spots.intensity; rt.spots.phase; zeros(2, numel(rt.spots))];
      data(:, :, 3) = [rt.spots.aperture; zeros(1, numel(rt.spots))];
      data(:, :, 4) = [rt.spots.line];
      
      % Id for the uniform
      id = 2;
      
      % Send the data (could be large so send it separately)
      if numel(rt.spots) > 50 || (~isempty(rt.use_texture) && rt.use_texture)
        data = permute(data, [2, 3, 1]);
        [varargout{1:nargout}] = rt.sendTexture(id, data./500.0 + 0.5, send);
      else
        data = permute(data, [1, 3, 2]);
        [varargout{1:nargout}] = rt.sendUniform(id, double(data(:)), send);
      end
      
    end
    
    function handleSetEvents(rt, src, ev)
      % Handle send events for properties
      
      if ~rt.live_update
        return;   % Nothing to do
      end
      
      switch src.Name
        case 'spots'
          
          if ~isempty(rt.use_texture) && (rt.use_texture || numel(rt.spots) <= 50)
            
            % Send number of spots
            rt.sendUniform(0, numel(rt.spots));
            
            % Send spots
            rt.sendSpots();
            
          else
            
            % Send shader and spots
            rt.updateAll();
            
          end
          
        case 'total_intensity'
          rt.sendUniform(1, rt.total_intensity);
        case 'centre'
          rt.sendUniform(3, rt.centre);
        case 'size'
          rt.sendUniform(4, rt.size);
        case 'focal_length'
          rt.sendUniform(5, rt.focal_length);
        case 'wavenumber'
          rt.sendUniform(6, rt.wavenumber);
        case 'blazing'
          rt.sendUniform(7, rt.blazing);
        case 'zernike'
          rt.sendUniform(8, rt.zernike);
          
        case 'use_texture'
          
          % Send shader and spots
          rt.updateAll();
          
        otherwise
          % Let the base class do everything else
          handleSetEvents@otslm.utils.RedTweezers.RedTweezers(rt, src, ev);
      end
    end
  end
end
