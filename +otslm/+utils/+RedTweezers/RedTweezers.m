classdef RedTweezers % < otslm.utils.Showable
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
  % Copyright 2018 Isaac Lenton
  % This file is part of OTSLM, see LICENSE.md for information about
  % using/distributing this file.
  
  properties
    udp_port     % UDP port to connect to
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
        port = 61557;   % VI has defaults for 61556 and 61557???
        if nargin < 1
          address = '127.0.0.1';
        end
      end
      
      % Open UDP port
      rt.udp_port = udp(address, port);
      fopen(rt.udp_port);
      
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
      
      % Write command
      fwrite(rt.udp_port, cmd);
    end
    
    function sendUniform(rt, id, value)
      % Sends an array of numers to the device and renders the pattern
      %
      % rt.sendUniform(id, [num, ...]) sends an array of numbers.
      % The array of numbers will be stored in uniform register id.
      % The first uniform in the program is id=0.
      % Array length must be less than 200 elements.
      
      % Don't know why, the manual says so
      assert(numel(value) <= 200, 'Number of values must be less than 200');
      
      % Create array of numbers
      cmd = sprintf('%g ', value);
      cmd(end) = [];
      
      % Add uniform tag
      cmd = ['<uniform id="' num2str(id) '">' cmd '</uniform>'];
      
      % Send command
      
      % Send command
      rt.sendCommand(cmd);
    end
    
    function setVsync(rt, value)
      % Synchronise updating with monitors refresh rate
      %
      % rt.setVsync(bool) change if pattern is drawn at same rate
      % as monitor refresh rate.  Typically should be enabled to
      % avoid tearing by may improve performance if disabled.
      
      % Form command
      cmd = sprintf('<swap_buffers_at_refresh_rate>%d</swap_buffers_at_refresh_rate>', value);
      
      % Send command
      rt.sendCommand(cmd);
    end
    
    function resizeWindow(rt, sz, monitor)
      % Resize the window
      %
      % rt.resizeWindow([x, y, width, height]) resize the window.
      %
      % rt.resizeWindow('fullscreen', monitor) make the window
      % fullscreen on the specified monitor.  monitor should be an
      % integer.  If unspecified, defaults to monitor = 1.
      
      assert(nargin == 1 || nargin == 2, 'Must supply 1 or 2 arguments');
      
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
      rt.sendCommand(cmd);

    end
    
    function setNetworkReply(rt, value)
      error('Not yet implemented');
    end
    
    function sendTexture(rt, id, texture)
      error('Not yet implemented');
    end
    
    function sendShader(rt, shader)
      % Send a shader to the device
      %
      % rt.sendShader() sends the default shader.
      % TODO: Do we want a default shader?
      %
      % rt.sendShader(shader) sends the text string for a custom
      % shader to the device.
      
      error('Not yet implemented');
      
    end
  end
end

