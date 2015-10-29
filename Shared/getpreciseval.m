function v = getpreciseval( im, x,y, varargin )
%GETPRECISEVAL Precise interpolated value of a position
%   v = GETPRECISEVAL(im, x, y, {Method})
%   
%   Returns value for  0.5 <= x,y < size(im) + 0.5, else NaN
%
%   Accepted methods are: 
%
%     'bilinear' (default)
%     'nearest'
%     'bicubic'

if nargin >= 4
  method = varargin{1};
else
  method = 'bilinear';
end

% %Find the points nearby
% padsize = 10;
% 
% xgv = round(x)-(padsize-1) : round(x)+(padsize-1);
% ygv = round(y)-(padsize-1) : round(y)+(padsize-1);
% 
% im = double(im);
% im = padarray(im,[padsize padsize],NaN);
% %Modify the other points accordingly
% xgv = xgv + padsize;
% ygv = ygv + padsize;
% x = x + padsize;
% y = y + padsize;

 im = double(im);
 [X_grid, Y_grid]  = meshgrid(1:size(im,1),1:size(im,2));
 
%  figure; surf(Y_grid', X_grid',im(ygv,xgv)); xlabel('y'); ylabel('x');
 
try 
 v = interp2(Y_grid', X_grid',im',y,x,method,NaN);
catch
 v = NaN;
end

 if isnan(v)
   %try nearest neighbour type at side points
  try 
    v = interp2(Y_grid', X_grid',im',y,x,'nearest',NaN);
  catch
    v = NaN;
  end
 end


end

