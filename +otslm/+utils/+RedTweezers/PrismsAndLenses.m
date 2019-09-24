classdef PrismsAndLenses < otslm.utils.RedTweezers.RedTweezers
  %PrismsAndLenses Prisms and Lenses algorithm for RedTweezers
  %
  % Implements the Prisms and Lenses algorithm in an OpenGl shader.
  %
  % Copyright 2019 Isaac Lenton
  % This file is part of OTSLM, see LICENSE.md for information about
  % using/distributing this file.
  
  % TODO: Need to change set methods to use callbacks
  
  properties
    spots           % Array of PrismsAndLenses spots
    total_intensity % Total intensity parameter used for intensity shaping
    centre          % Centre of the hologram as a function of its size
    size            % Size of the hologram (in microns)
    focal_length    % Focal length (in microns)
    wavenumber      % Wavenumber (inverse microns)
    blazing         % Blazing table for colourmap (32 numbers)
    zernike         % Zernike coefficients (12 numbers)
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
      ip.addParameter('nspots', 2);
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
    end
    
    function addSpot(rt, varargin)
      % Add a spot to the pattern
      
      error('Not yet implemented');
    end
    
    function removeSpot(rt, index)
      % Remove the specified spot from the pattern
      %
      % Can also directly modify the Spot array
      
      error('Not yet implemented');
    end
    
    function set.num_spots(rt, value)
      % Update the number of spots and send to the device
      
      error('Function will be replaced');
      
      assert(isnumeric(value) && isscalar(value), ...
        'Value must be numeric and scalar');
      
      rt.num_spots = value;
      
      % Update the device
      if rt.live_update
        rt.sendUniform(rt, 0, value);
      end
    end
    
    function updateSpots(rt)
      
      % We should add a similarly named function and put it in private
      
      error('Function will be replaced');
      
      % Update the spots uniform
      
      % spot parameters- each spot corresponds to 4 vec4, first one is x,y,z,l, second one is amplitude, -,-,-
      % element 0 x  y  z  l    (x,y,z in um and l is an integer)
      % element 1 intensity (I) phase -  -
      % element 2 na.x na.y na.r -  (the x, y position, and radius, of the spot on the SLM- useful for Shack-Hartmann holograms)
      % element 3 line trapping x y z and phase gradient.  xyz define the size and angle of the line, phase gradient (between +/-1) is the
      % scattering force component along the line.  Zero is usually a good choice for in-plane line traps
      
      % ID: 2
      
      error('Not yet implemented');
    end
    
    function set.total_intensity(rt, value)
      % Update the total intensity and send to the device
      
      assert(isnumeric(value) && isscalar(value), ...
        'Value must be numeric and scalar');
      
      rt.total_intensity = value;
      
      % Update the device
      if rt.live_update
        rt.sendUniform(rt, 1, value);
      end
    end
    
    function set.centre(rt, value)
      % Set the centre location of the pattern
      
      assert(numel(value) == 2, 'value must be 2 element vector');
      assert(isnumeric(value), 'value must be a pair of numbers');
      assert(all(value <= 1 && value >= 0), 'value must be between 0 and 1');
      
      rt.centre = value;
      
      % Update the device
      if rt.live_update
        rt.sendUniform(rt, 3, value);
      end
    end
    
    function set.size(rt, value)
      % Set the size of the hologram (in microns)
      
      assert(numel(value) == 2, 'value must be 2 element vector');
      assert(isnumeric(value), 'value must be a pair of numbers');
      
      rt.size = value;
      
      % Update the device
      if rt.live_update
        rt.sendUniform(rt, 4, value);
      end
    end
    
    function set.focal_length(rt, value)
      % Set the focal length (in microns)
      
      assert(isnumeric(value) && isscalar(value), 'value must be numeric scalar');
      
      rt.focal_length = value;
      
      % Update the device
      if rt.live_update
        rt.sendUniform(rt, 5, value);
      end
    end
    
    function set.wavenumber(rt, value)
      % Set the wavenumber (inverse microns)
      
      assert(isnumeric(value) && isscalar(value), 'value must be numeric scalar');
      
      rt.wavenumber = value;
      
      % Update the device
      if rt.live_update
        rt.sendUniform(rt, 6, value);
      end
    end
    
    function set.blazing(rt, value)
      % Set the blazing (lookup) table (must be 32 numbers)
      
      assert(numel(value) == 32, 'value must be a 32 element vector');
      assert(isnumeric(value), 'value must be numeric');
      assert(all(value <= 1 && value >= 0), 'values must be between 0 and 1');
      
      rt.blazing = value;
      
      % Update the device
      if rt.live_update
        rt.sendUniform(rt, 7, value);
      end
    end
    
    function set.zernike(rt, value)
      % Set the zernike coefficients for aberation correction (12 numbers)
      
      assert(numel(value) == 12, 'value must be a 32 element vector');
      assert(isnumeric(value), 'value must be numeric');
      
      rt.zernike = value;
      
      % Update the device
      if rt.live_update
        rt.sendUniform(rt, 8, value);
      end
    end
    
    function updateShader(rt)
      
      % Get the shader text
      shader = rt.shader_text;
      
      % Determine data type strings based on number of spots
      if rt.num_spots < 50
        spotsdecl = 'vec4 spots[200]';
        spotsret = 'spots[4*i +j]';
      else
        spotsdecl = 'sampler2D spots';
        spotsret = 'texture(spots, vec2( (float(j) +0.5) / 4.0, ( float(i) + 0.5) / float(n) ))*500.0 -250.0';
      end
      
      % Insert strings for the spot declarations
      shader = strrep(shader, '%%spotsdecl%%', spotsdecl);
      shader = strrep(shader, '%%spotsret%%', spotsret);
      
      % Send the shader
      rt.sendShader(shader);
      
    end
    
    function set.spots(rt, value)
      % Update the spots array
      
      assert(all(isa(value, 'ott.utils.PrismsAndLensesSpot')), ...
        'value must be an array of spots');
      
      rt.spots = value;   % TODO: Add a callback for sending the spots
    end
  end
end