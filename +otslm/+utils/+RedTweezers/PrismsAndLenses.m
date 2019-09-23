classdef PrismsAndLenses < otslm.utils.RedTweezers.RedTweezers
  %PrismsAndLenses Prisms and Lenses algorithm for RedTweezers
  %
  % Implements the Prisms and Lenses algorithm in an OpenGl shader.
  %
  % Copyright 2018 Isaac Lenton
  % This file is part of OTSLM, see LICENSE.md for information about
  % using/distributing this file.
  
  properties
    num_spots     % number of spots in the pattern
  end
  
  properties (Access=protected)
    shader_text   % Contents of the GLSL file
  end
  
  properties (Constant)
    glsl_filename = 'PrismsAndLenses.glsl';
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
      ip.addOptional('port', 61556);
      ip.addParameter('nspots', 2);
      ip.parse(varargin{:});
      
      % Load the prisms and lenses algorithm from the file
      our_filename = mfilename('fullpath');
      [our_path, ~, ~] = fileparts(our_filename);
      glsl_fullpath = [our_path, filesep, rt.glsl_filename];
      assert(exist(glsl_fullpath, 'file'), ...
        'Unable to file GLSL file');
      rt.shader_text = load(glsl_fullpath, '-ascii');
    end
    
    function set.num_spots(rt, value)
      % Update the number of spots and send to the device
      
      assert(isnumeric(value) && isscalar(value), ...
        'Value must be numeric and scalar');
      
      rt.num_spots = value;
      rt.sendUniform(rt, 0, value)
    end
    
    function set.total_intensity(rt, value)
      % Update the total intensity and send to the device
      
      assert(isnumeric(value) && isscalar(value), ...
        'Value must be numeric and scalar');
      
      rt.total_intensity = value;
      rt.sendUniform(rt, 1, value)
    end
    
    function updateSpots(rt)
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
    
uniform vec2 centre;        //=vec2(0.5,0.5);//centre of the hologram as a fraction of its size (usually 0.5,0.5)
uniform vec2 size;            //=vec2(7000,7000);//size of the hologram in microns
uniform float f;                 //=1600; //focal length in microns
uniform float k;                //=9.36; //wavevector in 1/microns
uniform float blazing[32]; //blazing function
uniform float zernikeCoefficients[12]; //zernike coefficients, matching the modes defined below
uniform vec3 zernx;        //=vec3(0.0,0.0,0.0);
uniform vec3 zerny;        //=vec3(0.0,0.0,0.0);
uniform vec3 zernz;        //=vec3(0.0,0.0,0.0);
    
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
  end
end