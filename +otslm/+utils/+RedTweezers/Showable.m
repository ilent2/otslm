classdef Showable < otslm.utils.RedTweezers.RedTweezers & otslm.utils.Showable
  % RedTweezers interface for displaying pre-computed patterns
  %
  % Loads a shader into RedTweezers for displaying images.
  % This is roughly equivilant to the ScreenDevice class.
  %
  % Copyright 2019 Isaac Lenton
  % This file is part of OTSLM, see LICENSE.md for information about
  % using/distributing this file.
  
  properties (SetAccess=protected)
    valueRange              % Range of values for screen
    lookupTable             % Lookup table for colour mapping
    patternType             % Pattern type
  end
  
  properties (Access=private, Hidden)
    preferred_size     % Prefered size for textures [rows, cols]
  end
  
  properties (Dependent)
    
    % Get/set the preferred size of the image texture [rows, cols].
    % If no prefered size is set, defaults to the RedTweezers window
    % size (if set) otherwise [512, 512].
    size
  end
  
  properties (SetAccess=protected)
    shader_text   % Contents of the GLSL file before substitution
  end
  
  properties (Constant)
    glsl_filename = 'Showable.glsl';   % Filename for GLSL source
  end
  
  methods
    function rt = Showable(varargin)
      % Connects to RedTweezers and loads the Prisms and Lenses shader
      %
      % rt = RedTweezers(...) connect to a running instance of RedTweezers.
      % Default address is 127.0.0.1 port 61556.
      %
      % rt = RedTweezers(address, port, ...) specifies a custom address/port.
      %
      % Accepts additional named arguments passed to Showable.
      %   'lookup_table'  table   Lookup table to use for device
      %       Default lookup table is value_range{1} repeated for each channel.
      %   'value_range'   table   Cell array of value ranges
      %       Default is 256x3 for a RGB screen
      %   'pattern_type'  str    Type of pattern the device displays.
      %       Default is 'amplitude'.  Can also be 'phase'.
      %   prescaledPatterns   bool   Default value for prescaled argument
      %       in show.  Default: false.
      
      % Parse inputs
      ip = inputParser;
      ip.addParameter('address', '127.0.0.1');
      ip.addParameter('port', 61557);
      ip.addParameter('prescaledPatterns', false);
      ip.addParameter('preferred_size', []);
      ip.addParameter('lookup_table', []);
      ip.addParameter('value_range', { 0:255, 0:255, 0:255 });
      ip.addParameter('pattern_type', 'amplitude');
      ip.parse(varargin{:});
      
      % Call base class constructors
      rt = rt@otslm.utils.RedTweezers.RedTweezers(...
        ip.Results.address, ip.Results.port);
      rt = rt@otslm.utils.Showable(...
        'prescaledPatterns', ip.Results.prescaledPatterns);
      
      % Generate the file path for the GLSL file
      our_filename = mfilename('fullpath');
      [our_path, ~, ~] = fileparts(our_filename);
      glsl_fullpath = [our_path, filesep, rt.glsl_filename];
      
      % Load the GLSL file
      rt.shader_text = rt.readGlslFile(glsl_fullpath);
      
      % Load the shader
      rt.sendShader(rt.shader_text);
      
      % Set other default values
      rt.preferred_size = ip.Results.preferred_size;
      rt.valueRange = ip.Results.value_range;
      rt.patternType = ip.Results.pattern_type;
      
      % Store or generate the lookup table
      if isempty(ip.Results.lookup_table)
        table = uint8(rt.valueRange{1}.');
        rt.lookupTable = repmat(table, ...
            [1, length(rt.valueRange)]);
      else
        rt.lookupTable = ip.Results.lookup_table;
      end
    end
    
    function varargout = sendShader(rt, shader, send)
      % Send a shader to the device
      %
      % rt.sendShader() sends the default text string to RedTweezers.
      %
      % rt.sendShader(shader, send) sends the specified text instead.
      % If send is false, the command isn't sent.  Default value for
      % send is nargout == 0
      
      % Handle default arguments
      if nargin < 3
        send = nargout == 0;
        if nargin < 2
          shader = rt.shader_text;
        end
      end
      
      % Call base method
      [varargout{1:nargout}] = ...
        sendShader@otslm.utils.RedTweezers.RedTweezers(rt, shader, send);
    end
    
    function showRaw(rt, img)
      % Show the pattern on the device (update the texture)
      %
      % rt.showRaw() clears the screen.
      %
      % rt.showRaw(img) display an image on the screen.
      % The image should have 1 or 3 channels.
      %
      % Images must be single, double or unit8.  Float images
      % should be in range [0, 1), uint8 in range [0, 256).
      
      if nargin < 2
        img = zeros([obj.size, 3], 'uint8');
      end
      
      assert(isfloat(img) || isa(img, 'uint8'), ...
        'Image must be either uint8 or float type');
      
      % Check size of image, repeat layers if needed
      if size(img, 3) == 1
        img = repmat(img, [1, 1, 3]);
      elseif size(img, 3) ~= 3
        error('Image size must be NxMx1 or NxMx3');
      end

      % Clear any values which are NAN
      if any(isnan(img))
        img(isnan(img)) = 0;
      end

      % Convert image from double to uint8
      if isfloat(img)
        if any(img(:) < 0 | img(:) >= 1)
          warning('RedTweezers:Showable:double_outside_range', ...
            'Double/single images should be in range [0, 1)');
        end
        img = uint8(img*256);
      end
      
      % Send the texture to the device
      rt.sendTexture(0, img);
    end
    
    function val = get.size(rt)
      % Get the preferred size
      if ~isempty(rt.preferred_size)
        % The user has already specified it
        val = rt.preferred_size;
        
      elseif ~isempty(rt.window)
        % Get it from the window
        if iscell(rt.window)
          % Fullscreen (get screen size)
          set(0, 'units', 'pixels')  
          scsz = get(0, 'ScreenSize');
          val = fliplr(scsz(rt.window{2}, 3:4));
        else
          val = fliplr(rt.window(3:4));
        end
        
      else
        % Fallback value
        val = [512, 512];
      end
    end
    
    function set.size(rt, value)
      % Set the preferred size
      
      if isempty(value)
        % Nothing to check
      else
        assert(numel(value) == 2, 'value must be empty or 2 element vector');
        assert(isnumeric(value), 'value must be numeric');
        assert(all(round(value) == value), 'value must be integer');
      end
      
      % Store preferred value
      rt.preferred_size = value;
    end
  end
end
