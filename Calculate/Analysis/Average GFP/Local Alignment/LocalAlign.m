function imout = LocalAlign( image, AlignParams )
%LOCALALIGN Summary of this function goes here
%   Detailed explanation goes here


[N, M] = size(image);

imout = spatial_interp(double(image), AlignParams.Twarp, 'cubic', AlignParams.settings.transform, 1:N, 1:M);

end

