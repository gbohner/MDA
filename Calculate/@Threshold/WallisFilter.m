function WallisFilter(obj, Md, Dd, Amax, p, W, varargin )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

if mod(W,2)==0
    W = W+1;
end

w = floor(W/2);

F = double(obj.output);

if size(varargin) > 0
    if varargin{1} == 1
%         gauss_blur = 1/273 * [1 4 7 4 1; 4 16 26 16 4; 7 26 41 26 7; 4 16 26 16 4; 1 4 7 4 1];
%         F = conv2(F, gauss_blur, 'same');

      gauss_blur = fspecial('gaussian', W, 1);
      F = conv2(F, gauss_blur, 'same');
    end
end

convNumEl = ones(size(F));

M = conv2(F,ones(W),'same')./conv2(convNumEl,ones(W),'same');

D = (conv2((F-M).^2,ones(W),'same')/(W^2)).^0.5;

G = (F-M) .* Amax .* Dd ./ (Amax .* D + Dd) + p * Md + (1-p) * M;

G(G<0) = 0;
G(G>65534) = 65534;

obj.output = uint16(G);

end

