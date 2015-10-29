function bg = GetBgInt( image )
%GETBGINT Summary of this function goes here
%   Detailed explanation goes here



% bg = mean(image(image<=min(image(:))*2));

maxim = max(image(:));
minim = min(image(:));

cutoff = minim + (maxim - minim) * 0.2;

bg = mean(image(image<cutoff));

end

