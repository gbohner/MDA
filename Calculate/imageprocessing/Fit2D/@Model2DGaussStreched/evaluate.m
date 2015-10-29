function [ f, xb ] = evaluate( model, x )
  global xg yg
  
  if nargout == 1 % calculate value of function
    
    x0 = x(1);
    y0 = x(2);
    ori = x(3);
    psf = x(4);
    w = x(5);
    h = x(6);
    
     f = h.*(exp(-0.5*(abs(-sin(ori).*(xg-x0) + cos(ori).*(yg-y0))).^2 ./psf^2).*...
       exp(-0.5*abs((cos(ori).*(xg-x0) + sin(ori).*(yg-y0))).^2 ./ w^2));
                
  else % calculate value of function and jacobian 'xb'
  
  end
  
end