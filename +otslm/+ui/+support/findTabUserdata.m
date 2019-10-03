function userdata = findTabUserdata(tab, tag)
% Find entries with the specific user-data tag and returns a struct
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

userdata = struct();

for ii = 1:length(tag)
  
  tag_str = tag{ii};

  entries = findall(tab, 'UserData', tag_str);
  userdata.(tag_str) = entries;
  
end