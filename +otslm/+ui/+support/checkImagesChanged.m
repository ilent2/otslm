function changed = checkImagesChanged(oldImages, newImages)
% Compare two cell arrays of images for changes
%
% changed = checkImagesChanged(oldImage, newImages) compares each
% image in the two cell arrays for differences.  If the cell arrays
% are different, returns true.
%
% Copyright 2019 Isaac Lenton
% This file is part of OTSLM, see LICENSE.md for information about
% using/distributing this file.

% Check the number of images is equal
changed = length(newImages) ~= length(oldImages);

% Check contents of images are equal
if ~changed
    for ii = 1:length(newImages)
        if ~strcmpi(class(newImages{ii}), class(oldImages{ii})) ...
            || any(size(newImages{ii}) ~= size(oldImages{ii})) ...
            || any(newImages{ii}(:) ~= oldImages{ii}(:))
          changed = true;
          break;
        end
    end
end

end