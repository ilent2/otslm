classdef RedTweezers < handle
% Interface to RedTweezers.
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
% Methods
%   - RedTweezers   -- Construct an instance of this object
%   - sendCommand   -- Send a command (adds data block wrapper)
%   - updateAll     -- Resend all commands
%   - readGlslFile  -- Read a GLSL file into a character array
%
% Properties
%   - udp_port    -- port of RedTweezers server
%   - live_update -- True if property changes should be sent to
%     RedTweeezers immediately, otherwise ``updateAll`` can be used
%     to send properties at a later time.
%
% RedTweezers properties
%   - vsync (logical) -- Synchronise updating with monitor refresh rate
%   - window (cell|numeric) -- Size of the window [x, y, width, height] or
%     {'fullscreen', monitor_id} for fullscreen.  Use ``resizeWindow``
%     to change the window size.
%   - network_reply (logical) -- If True, requests RedTweezers server
%     sends a reply.
%
% See also RedTweezers, :class:`Showable` and :class:`PrismsAndLenses`.

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

  methods (Static)
    function contents = readGlslFile(filename)
      % Read a GLSL file into a character array
      %
      % Usage
      %   contents = RedTweezers.readGlslFile(filename)
      %   Returns a character vector with file contents.
      %
      % Parameters
      %   - filename (char) -- GLSL file to read

      % Check file exists
      assert(2 == exist(filename, 'file'), 'Unable to find GLSL file');
      
      % Read contents of file
      fid = fopen(filename, 'r');
      contents = fread(fid, 'uint8=>char');
      fclose(fid);
      
      % Make the rows go across the page (string style)
      contents = contents.';
    end
  end
  
  methods
    function rt = RedTweezers(address, port)
      % RedTweezers construct a new RedTweezers interface
      %
      % Usage
      %   rt = RedTweezers([address, port]) specifies a custom address/port.
      %
      % Parameters
      %   - address -- IP address, passed to :func:`udp`.
      %     (default: '127.0.0.1').
      %   - port    -- UDP port to connect to (default: 61556).

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
      % Usage
      %   rt.sendCommand(cmd) sends the command string to the device and
      %   adds the data block.
      %
      % Parameters
      %   - cmd (char) -- command string to send to device

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
      % Usage
      %   rt.updateAll([send]) send all commands to the device.
      %
      %   cmd = rt.updateAll([send]) send all commands to the device and
      %   return the string that is sent.
      %
      % Parameters
      %   - send (logical) -- If send is False, don't actually send the
      %     commands to the device.  (default: nargout == 0)

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
    
    function cmd = sendUniform(rt, id, values, send)
      % Sends an array of namers to the device and renders the pattern
      %
      % Usage
      %   cmd = rt.sendUniform(id, values, [send]) sends an array of numbers.
      %   The array of numbers will be stored in uniform register id.
      %   The first uniform in the program is id=0.
      %   Array length must be less than 200 elements.
      %   Returns the string for the command.
      %
      % Parameters
      %   - id (numeric)     -- OpenGL register to store values in
      %   - values (numeric) -- array of values to send
      %   - send (logical)   -- If send is false, the command isn't sent.
      %     (default: nargout == 0)

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
    
    function cmd = sendTexture(rt, id, texture, varargin)
      % Send a texture blob to the device
      %
      % Usage
      %   cmd = sendTexture(id, texture, [send, ...])
      %
      % Paramters
      %   - id -- OpenGL uniform id to store texture at
      %   - texture -- The texture.  Should be a 4xWxH in RGBA order.
      %     If the texture is a 3xWxH uint8 matrix, the function
      %     adds 255 for the A channel.
      %   - send (logical)   -- If send is false, the command isn't sent.
      %     (default: nargout == 0)
      %
      % Optional named arguments
      %   - endian (enum) -- 'L' or 'B' endian-ness of byte stream (for float)

      % Get the default endian-ness (our endianness)
      [~,~,our_endian] = computer();
      
      ip = inputParser;
      ip.addOptional('send', nargout == 0);
      ip.addParameter('endian', our_endian);
      ip.parse(varargin{:});
      
      % Handle default send argument
      if nargin < 4
        send = nargout == 0;
      end
      
      assert(isa(texture, 'uint8') || isfloat(texture), ...
        'texture must be uint8 or float matrix');
      assert(ndims(texture) == 3, 'texture must be 3 dimensional matrix');
      assert((size(texture, 3) == 3 && isa(texture, 'uint8')) || size(texture, 3) == 4, ...
        'texture must be NxMx4 or NxMx3 uint8 matrix');
      
      % Add alpha channel to array
      if size(texture, 3) == 3 && ~isfloat(texture)
        texture(:, :, 4) = uint8(255);
      end
      
      % Ensure data is uint8 or float
      if isfloat(texture)
        texture = single(texture);
      end
      
      % Change order of numbers to RGBAxNxM and convert to vector
      data = permute(texture, [3, 2, 1]);
      
      % We only support one format (RedTweezers has packedfloat too)
      if isfloat(texture)
        format = 'packedfloat';
        
        % Change byte order if needed
        if ip.Results.endian ~= our_endian
          
          % Convert texture to uint32 and swap
          data = typecast(data, 'uint32');
          data = swapbytes(data);
        end
        
      else
        format = 'packedu8';
      end
      
      % Convert texture to uint8
      data = typecast(data(:), 'uint8');
      
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
      % Usage
      %   cmd = rt.sendShader(shader, [send])
      %
      % Parameters
      %   - shader (char)    -- shader character vector.
      %   - send (logical)   -- If send is false, the command isn't sent.
      %     (default: nargout == 0)

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
          
        otherwise
          warning('Unhandled set event');
      end
    end
  end
end

