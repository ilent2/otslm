function userdata = findTabUserdata(tab, tag)
% Find entries with the specific user-data tag and returns a struct
%
% Usage
%   userdata = findTabUserdata(tab, tag)
%
% Parameters
%   - tab -- An object which can be passed to ``findall``
%   - tag -- Cell array of values for UserData property to search for
%
% Returns
%   ``struct`` with fields corresponding to ``tag`` values
%
% This function uses ``findall`` to search the given ``Tab`` for entries
% whose ``UserData`` attribute is set to one of the specified strings.
% ``tag`` should be a cell array of character vectors for the tags
% to search for. Example usage (based on :class:`ui.tools.SampleRegion`):
%
% .. code-block::
%
%   entry = otslm.ui.support.findTabUserdata(tab, ...
%     {'location', 'target', 'radius'});
%   entry.location.ValueChangedFcn = createCallbackFcn(...
%     app, @patternValueChanged, true);
%   entry.target.Value= 'test';

% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

userdata = struct();

for ii = 1:length(tag)

  tag_str = tag{ii};

  entries = findall(tab, 'UserData', tag_str);
  userdata.(tag_str) = entries;

end

