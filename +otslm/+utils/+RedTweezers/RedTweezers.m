classdef RedTweezers < handle
  %RedTweezers interface to RedTweezers
  %
  % RedTweezers is a software package which calculates the hologram
  % using OpenGL and directly displays the hologram on the hardware.
  % This has the advantage over other methods that it does not require
  % the pattern to be downloaded from the graphics hardware and
  % re-uploaded for display on the hardware.
  %
  % This class connects to RedTweezers via UDP.
  % The RedTweezers library must be running for this to work.
  %
  % For details and download link, see the RedTweezers CPC paper:
  % https://doi.org/10.1016/j.cpc.2013.08.008
  %
  % Methods:
  %   RedTweezers    Construct an instance of this object
  %   sendCommand    Send a command (adds data block wrapper)
  %   updateAll      Resend all commands
  %
  % See also otslm.utils.RedTweezers.PrismsAndLenses
  %
  % Copyright 2019 Isaac Lenton
  % This file is part of OTSLM, see LICENSE.md for information about
  % using/distributing this file.
  
  properties (SetAccess=protected)
    udp_port      % UDP port to connect to
  end
  
  properties
    live_update   % If changing properties should update the device
  end
  
  properties (SetObservable)  
    
    % (bool) Synchronise updating with monitors refresh rate
    vsync
    
    % Size of the window [x, y, width, height] or
    % {'fullscreen', monitor_id} for fullscreen.
    window
    
    % (bool) If a network reply should be requested
    network_reply
  end
  
  methods
    function rt = RedTweezers(address, port)
      % RedTweezers construct a new RedTweezers interface
      %
      % rt = RedTweezers() connect to a running instance of RedTweezers.
      % Default address is 127.0.0.1 port 61556.
      %
      % rt = RedTweezers(address, port) specifies a custom address/port.
      
      % Handle default arguments
      if nargin < 2
        port = 61557;
        if nargin < 1
          address = '127.0.0.1';
        end
      end
      
      % Open UDP port
      rt.udp_port = udp(address, port);
      fopen(rt.udp_port);
      
      % Default is to live update the device
      rt.live_update = true;
      addlistener(rt, 'vsync', 'PostSet', @rt.handleSetEvents);
      addlistener(rt, 'window', 'PostSet', @rt.handleSetEvents);
      addlistener(rt, 'network_reply', 'PostSet', @rt.handleSetEvents);
      
    end
    
    function delete(rt)
      % Clean up (close UDP port)
      fclose(rt.udp_port);
    end
    
    function sendCommand(rt, cmd)
      % Send a command string to the device
      %
      % rt.sendCommand(cmd) sends the comand string to the device and
      % adds the data block.
      
      % Add data block arround cmd
      cmd = ['<data>', cmd, '</data>'];
      
      % Check max buffer length
      max_buffer_length = 655360;   % From RedTweezers (default)
      if numel(cmd) > max_buffer_length
        error('Number of values to write exceeds max buffer length');
      end
      
      if numel(cmd) >= rt.udp_port.OutputBufferSize
        % Split the command into packets
        for ii = 1:rt.udp_port.OutputBufferSize:numel(cmd)
          fwrite(rt.udp_port, cmd(ii:(min(ii+512-1, numel(cmd)))));
        end
      else
        % Write command
        fwrite(rt.udp_port, cmd);
      end
    end
    
    function varargout = updateAll(rt, send)
      % Resends all information to RedTweezers
      %
      % Only sends set options (leaves others at RedTweezers defaults)
      %
      % If send is false, the command isn't sent.  Default value for
      % send is nargout == 0
      
      % Handle default send argument
      if nargin < 2
        send = nargout == 0;
      end
      
      cmds = [];
      
      if ~isempty(rt.vsync)
        cmds = [cmds, rt.setVsync(rt.vsync, false)];
      end
      
      if ~isempty(rt.window)
        if iscell(rt.window)
          cmds = [cmds, rt.resizeWindow(rt.window{:}, false)];
        else
          cmds = [cmds, rt.resizeWindow(rt.window, false)];
        end
      end
      
      if ~isempty(rt.network_reply)
        cmds = [cmds, rt.setNetworkReply(rt.network_reply, false)];
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
    
    function cmd = sendUniform(rt, id, value, send)
      % Sends an array of numers to the device and renders the pattern
      %
      % rt.sendUniform(id, [num, ...]) sends an array of numbers.
      % The array of numbers will be stored in uniform register id.
      % The first uniform in the program is id=0.
      % Array length must be less than 200 elements.
      %
      % If send is false, the command isn't sent.  Default value for
      % send is nargout == 0
      
      % Handle default send argument
      if nargin < 4
        send = nargout == 0;
      end
      
      % Don't know why, the manual says so
      assert(numel(value) <= 200, 'Number of values must be less than 200');
      
      % Create array of numbers
      cmd = sprintf('%g ', value);
      cmd(end) = [];
      
      % Add uniform tag
      cmd = ['<uniform id="' num2str(id) '">' cmd '</uniform>'];
      
      % Send commands
      if send
        rt.sendCommand(cmd);
      end
    end
    
    function set.vsync(rt, value)
      % (bool) Synchronise updating with monitors refresh rate
      %
      % Change if pattern is drawn at same rate
      % as monitor refresh rate.  Typically should be enabled to
      % avoid tearing by may improve performance if disabled.
      
      assert(islogical(value), 'value must be logical');
      assert(isscalar(value), 'value must be scalar');
      
      rt.vsync = value;
    end
    
    function set.window(rt, value)
      % [x, y, width, height] Resize the window
      
      if iscell(value)
        % Fullscreen options
        assert(numel(value) == 2, 'Value must be 2 element cell array');
        assert(strcmpi('fullscreen', value{1}), 'First value must be fullscreen');
        assert(isnumeric(value{2}) && isscalar(value{2}), 'Second value must be numeric scalar');
        
      else
        assert(isnumeric(value), 'value must be numeric');
        assert(numel(value) == 4, 'value must have 4 elements');
      
      end
      
      rt.window = value;
    end
    
    function set.network_reply(rt, value)
      % (bool) Set the network_reply value
      
      assert(islogical(value), 'value must be logical');
      assert(isscalar(value), 'value must be scalar');
      
      rt.network_reply = value;
    end
    
    function cmd = sendTexture(rt, id, texture, send)
      % Send a texture blob to the device
      %
      % sendTexture(id, texture, send) sends the texture to the uniform
      % with the specified id.  The texture should be a 4*w*h in RGBA
      % order.
      %
      % If send is false, the command isn't sent.  Default value for
      % send is nargout == 0
      
      % Handle default send argument
      if nargin < 4
        send = nargout == 0;
      end
      
      assert(isa(texture, 'uint8'), 'texture must be uint8 matrix');
      assert(ndims(texture) == 3, 'texture must be 3 dimensional matrix');
      assert(size(texture, 3) == 3 || size(texture, 3) == 4, ...
        'texture must be NxMx4 or NxMx3 matrix');
      
      % Add alpha channel to array
      if size(texture, 3) == 3
        texture(:, :, 4) = 255;
      end
      
      % Convert texture to uint8 blob
      data = cast(texture, 'char');
      
      % Change order of numbers to RGBAxNxM and convert to vector
      data = permute(data, [3, 2, 1]);
      data = data(:);
      
      % We only support one format (RedTweezers has packedfloat too)
      format = 'packedu8';
      
      % Generate the command string
      cmd = sprintf(['<texture id="%d" width="%d" height="%d" format="%s">', ...
          '<binary size="%d">%s</binary></texture>'], ...
          id, size(texture, 2), size(texture, 1), format, numel(data), data);
      
      % Send command
      if send
        rt.sendCommand(cmd);
      end
    end
    
    function cmd = sendShader(rt, shader, send)
      % Send a shader to the device
      %
      % rt.sendShader(shader) sends the text string for a custom
      % shader to the device.
      %
      % If send is false, the command isn't sent.  Default value for
      % send is nargout == 0
      
      % Handle default send argument
      if nargin < 3
        send = nargout == 0;
      end
      
      % Generate the command string
      cmd = sprintf('<shader_source>%s</shader_source>', shader);
      
      % Send command
      if send
        rt.sendCommand(cmd);
      end
    end
  end
    
  % These methods are called by the set.* methods of the related
  % parameters.  They can be used to get the formatted command string.
  methods (Hidden)
    
    function cmd = setVsync(rt, value, send)
      % Synchronise updating with monitors refresh rate
      %
      % rt.setVsync(value, send) change if pattern is drawn at same rate
      % as monitor refresh rate.  Typically should be enabled to
      % avoid tearing by may improve performance if disabled.
      %
      % If send is false, the command isn't sent.  Default value for
      % send is nargout == 0
      
      if nargin < 3
        send = nargout == 0;
      end
      
      % Form command
      cmd = sprintf('<swap_buffers_at_refresh_rate>%d</swap_buffers_at_refresh_rate>', value);
      
      % Send command
      if send
        rt.sendCommand(cmd);
      end
    end
    
    function cmd = resizeWindow(rt, sz, monitor, send)
      % Resize the window
      %
      % rt.resizeWindow([x, y, width, height], send) resize the window.
      %
      % rt.resizeWindow('fullscreen', monitor, send) make the window
      % fullscreen on the specified monitor.  monitor should be an
      % integer.  If unspecified, defaults to monitor = 1.
      %
      % If send is false, the command isn't sent.  Default value for
      % send is nargout == 0
      
      % Handle default send value
      if ischar(sz)
        % Fullscreen (rt, char, num, [send])
        if nargin < 4
          send = nargout == 0;
        end
      else
        % Fullscreen (rt, num, [send])
        if nargin < 3
          send = nargout == 0;
        else
          send = monitor;
        end
      end
      
      % Generate command
      if ischar(sz)
        assert(strcmpi(sz, 'fullscreen'), 'Invalid string argument');
        if nargin == 2
          monitor = 1;
        end
        cmd = sprintf('<window_rect>all monitor %d</window_rect>', monitor);
      else
        assert(isnumeric(sz) && numel(sz) == 4, ...
          'sz must be numeric with 4 elements');
        cmd = sprintf('<window_rect>%d, %d, %d, %d</window_rect>', sz);
      end
      
      % Send command
      if send
        rt.sendCommand(cmd);
      end
    end
    
    function cmd = setNetworkReply(rt, value, send)
      % Tell RedTweezers to send a reply to our messages
      %
      % If send is false, the command isn't sent.  Default value for
      % send is nargout == 0
      
      assert(islogical(value), 'value must be logical');
      assert(isscalar(value), 'value must be scalar');
      
      % Handle default send argument
      if nargin < 3
        send = nargout == 0;
      end
      
      cmd = sprintf('<network_reply>%d</network_reply>', value);
      
      % Send command
      if send
        rt.sendCommand(cmd);
      end
    end
    
    function handleSetEvents(rt, src, ~)
      % Handle send events for properties
      
      if ~rt.live_update
        return;   % Nothing to do
      end
      
      switch src.Name
        case 'vsync'
          rt.setVsync(value);
          
        case 'window'
          if iscell(rt.window)
            rt.resizeWindow(rt.window{:});
          else
            rt.resizeWindow(rt.window);
          end
          
        case 'network_reply'
          rt.setNetworkReply(value);
      end
    end
  end
end

