function [ f, xb ] = evaluate( model, x )
  global xg yg
  
  
  if nargout == 1 % calculate value of function
    
%     f = x(6) * GaussianStripExpConvoluted( x ); 

    x0  = x(1);
    y0  = x(2);
    ori = mod(x(3),2*pi);
    psf = x(4);
    w   = x(5);
    A   = x(6);
    tau = x(7);

    f = exp(-0.5*(abs(-sin(ori).*(xg-x0) + cos(ori).*(yg-y0))).^2 ./psf^2).*...
      A./(2.*tau).*exp(0.5.*w.^2./tau.^2 - (-cos(ori).*(xg-x0) - sin(ori).*(yg-y0))./tau).*...
      erfc(1./sqrt(2).*( w./tau - (-cos(ori).*(xg-x0) - sin(ori).*(yg-y0))./w));
    
%     if (size(f,1) > 2* size(f,2)) || size(f,2) > 2* size(f,1)
%       surf(double(reshape(f,sqrt(length(f)),[])));
%     else
%       surf(double(f))
%     end
%     pause(0.01);
%     disp(x)
  
  else % calculate value of function and jacobian 'xb'

%     xb = zeros( numel( xg ), 6 ); % allocate memory
%     
%     % call subfunctions
%     [ w, wb ] = HalfPlane( [ x(1:2) x(3) - pi/2 ] );
%     [ g, gb ] = GaussianStrip( x(1:4) );
% 
%     % forward calculation
%     temp = ( ( xg-x(1) ).^2 + ( yg-x(2) ).^2 ) ./ x(4);
%     temp0 = exp( -temp );
%     tempb = -( w .* temp0 .* x(6) ./ x(4) );
% 
%     % calculate contribution of subfunctions to -jacobian
%     gb = gb .* repmat( (1-w) .* x(6), 1, 4 );
%     wb = wb .* repmat( ( temp0 - g ) .* x(6), 1, 3 );
%     
%     % add contributions to -jacobian
%     xb(:,1) = 2.0 .* (xg-x(1)) .* tempb - gb(:,1) - wb(:,1);
%     xb(:,2) = 2.0 .* (yg-x(2)) .* tempb - gb(:,2) - wb(:,2);
%     xb(:,3) = - gb(:,3) - wb(:,3);
%     xb(:,4) = temp .* tempb - gb(:,4);
%     xb(:,6) = - ( w .* temp0 + (1-w) .* g );
%     % calculation of function value
%     f = - x(6) .* xb(:,6);
    
  end

end