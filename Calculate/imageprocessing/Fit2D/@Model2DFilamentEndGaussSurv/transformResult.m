function value = transformResult( model, x, xe, data )
  value.x = double_error( x(1:2) + data.offset, xe(1:2) );
  value.o = double_error( mod( x(3), 2*pi ), xe(3) );
  value.w = double_error( x(4:5), xe(4:5) );
  value.h = double_error( x(6), xe(6) );
  value.r = double_error( [] );
  value.b = data.background;
  value.l = double_error( [] );
  
%   %Calculate the classic end of microtubule (thresh = 0.95);
%   i1 = 0; thresh = 0.95; step = 0.1;
%   while normcdf( i1, 0, sqrt(x(4).^2 + x(5).^2)) < thresh
%      i1 = i1 + step;
%   end;
%   value.l = double_error( x(1:2)+data.offset + i1*[cos(x(3)), sin(x(3))], xe(1:2) );
end