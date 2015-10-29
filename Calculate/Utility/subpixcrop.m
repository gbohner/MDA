function v = subpixcrop( im, pos, cropsize, resize )
%SUBPIXCROP Summary of this function goes here
%   Detailed explanation goes here

%Output image is a cropped image around the given position, image size is floor(cropsize * resize + 1)

global Config Gui

method = Config.analysis.advanced.interpmethod;

% method = 'cubic';
method = 'nearest';

s = whos('im');

im = double(im);
[X_grid, Y_grid]  = meshgrid(1:size(im,1),1:size(im,2));

givewarning = 0;
if (pos(1) < cropsize(1)/2 + 1), pos(1) = cropsize(1)/2 + 1;  givewarning = 1; end;
if (pos(2) < cropsize(2)/2 + 1), pos(2) = cropsize(2)/2 + 1;  givewarning = 1; end;
if (pos(1) > size(im,1) - cropsize(1)/2 - 1), pos(1) = size(im,1) - cropsize(1)/2 - 1;  givewarning = 1; end;
if (pos(2) > size(im,2) - cropsize(2)/2 - 1), pos(2) = size(im,2) - cropsize(2)/2 - 1;  givewarning = 1; end;

if givewarning
	warning('Filament growing off the area of recording');
end

% [xi, yi] = meshgrid(pos(1) - cropsize(1)/2 : 1/resize : pos(1) + cropsize(1)/2,...
%                     pos(2) - cropsize(2)/2 : 1/resize : pos(2) + cropsize(2)/2);

F = griddedInterpolant(X_grid',Y_grid',im',method);

[xi, yi] = ndgrid(pos(1) - cropsize(1)/2 : 1/resize : pos(1) + cropsize(1)/2,...
                 pos(2) - cropsize(2)/2 : 1/resize : pos(2) + cropsize(2)/2);

try 
%  v = interp2(Y_grid', X_grid',im',yi,xi,method,NaN);
  v = F(xi, yi)';
catch
 v = NaN(cropsize);
end

v = cast(v, s.class);

% axes(Gui.handles.right.axes);
% axis ij;
% axis image;
% imagesc(v); pause(0.1);

end

