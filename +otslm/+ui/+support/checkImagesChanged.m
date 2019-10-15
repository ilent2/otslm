function changed = checkImagesChanged(oldImages, newImages)
% Compare two cell arrays of images for changes
%
% Usage
%   changed = checkImagesChanged(oldImage, newImages) compares each
%   image in the two cell arrays for differences.  If the cell arrays
%   are different, returns true.
%
% Parameters
%   - oldImages -- first cell array of images to compare
%   - newImages -- second cell array of images to compare
%
% Returns
%   - changed (logical) -- if the images have changed
%
% This function is used by most methods which have an input image,
% including :class:`ui.tools.Visualise`, :class:`ui.tools.Finalize` and
% :class:`ui.tools.Dither`. The two inputs contain cell arrays of matrices
% to be compared. If either the length of the cell arrays, size or type of
% the images, or the image data are different, the function returns true.
% This can be a expensive comparison. We look for changes between the old
% and new images rather than watching for a change event on variables,
% this is to allow the user to enter constants or procedural functions
% into the GUI inputs.

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
