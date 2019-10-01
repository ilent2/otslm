classdef PrismsAndLensesSpot
  % Properties definition for a PrismsAndLenses spot
  %   This class is for use with PrismsAndLenses.
  
  properties
    position      % Position of spot [x; y; z]
    oam           % Orbital angular momentum charge number (int)
    
    phase         % Phase of the spot
    intensity     % Intensity of the spot
    
    aperture      % Aperture to define hologram within [x; y; radius]
    
    line          % Line trap direction and phase [x; y; z; phase]
  end
  
  methods
    function obj = PrismsAndLensesSpot(varargin)
      % Declares a new spot for PrismsAndLenses
      %
      % PrismsAndLensesSpot(position, ...) declares a new spot at
      % the specified position [x, y, z].
      %
      % Optional named parameters:
      %   'oam'    int    Vortex charge
      %   'phase'  float  Phase offset for the spot
      %   'intensity' float  Intensity for the spot
      %   'aperture'  [x, y, R]  Position and radius of aperture
      %   'line'   [x, y, z, phase] Direction, length and phase of line
      
      ip = inputParser;
      ip.addOptional('position', [0, 0, 0]);
      ip.addParameter('oam', 0);
      ip.addParameter('phase', 0);
      ip.addParameter('intensity', 1);
      ip.addParameter('aperture', [0, 0, 1]);
      ip.addParameter('line', [0, 0, 0, 0]);
      ip.parse(varargin{:});
      
      % Store parameters
      obj.position = ip.Results.position;
      obj.oam = ip.Results.oam;
      obj.phase = ip.Results.phase;
      obj.intensity = ip.Results.intensity;
      obj.aperture = ip.Results.aperture;
      obj.line = ip.Results.line;
    end
    
    function obj = set.position(obj, value)
      % Set the spot position
      
      assert(isnumeric(value), 'value must be numeric');
      assert(numel(value) == 3, 'value must be 3 element vector');
      
      obj.position = value(:);
    end
    
    function obj = set.oam(obj, value)
      % Set the spot vortex number
      
      assert(isnumeric(value) && isscalar(value), 'value must be numeric scalar');
      assert(round(value) == value, 'value must be integer');
      
      obj.oam = value;
    end
    
    function obj = set.phase(obj, value)
      % Set the phase of the spot
      
      assert(isnumeric(value) && isscalar(value), 'value must be numeric scalar');
      
      obj.phase = value;
    end
    
    function obj = set.intensity(obj, value)
      % Set the phase of the spot
      
      assert(isnumeric(value) && isscalar(value), 'value must be numeric scalar');
      
      obj.intensity = value;
    end
    
    function obj = set.aperture(obj, value)
      % Set the aperture parameters
      
      assert(isnumeric(value), 'value must be numeric');
      assert(numel(value) == 3, 'value must be 3 element vector');
      
      obj.aperture = value(:);
    end
    
    function obj = set.line(obj, value)
      % Set the line parameters
      
      assert(isnumeric(value), 'value must be numeric');
      assert(numel(value) == 4, 'value must be 3 element vector');
      assert(value(4) >= -1 && value(4) <= 1, 'phase must be between -1 and 1');
      
      obj.line = value(:);
    end

  end
end

