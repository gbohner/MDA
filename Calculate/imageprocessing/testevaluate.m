function [ f, xb ] = testevaluate( x,xg,yg, offset )
  %global xg yg
  
  sf = 1.6; %scaling factor;
  sf = 1/sf;

  rad = -x(3);
  
  sM = [sf * cos(rad)^2 + 1 * sin(rad)^2,  1 * cos(rad) * sin(rad) - sf * cos(rad) * sin(rad) ;...
                 1 * cos(rad) * sin(rad) - sf * cos(rad) * sin(rad), 1 * cos(rad)^2 + sf * sin(rad)^2 ];
  


  
  if nargout == 1 % calculate value of function
    
    w = testHalfPlane( [ x(1:2) x(3) - pi/2 ], xg,yg, offset );
%     f = x(5) * ( (1 - w) .* ( exp( -( (xg-x(1)).^2 + (yg-x(2)).^2 ) / x(4)^2 ) ) ) + ...
%                 w .* testGaussianStripExp( x, xg,yg, offset ) ;

    f = x(5) * ( (1 - w) .* ( exp( -( ...
                 (sM(1,1)*(xg-x(1)) + sM(1,2) * (yg-x(2))).^2  + ...
                  (sM(2,1)*(xg-x(1)) + sM(2,2) * (yg-x(2))).^2      ) ...
                / x(4)^2 ) ) + ...
                w .* testGaussianStripExp( x, xg,yg, offset, sf ) );  

  else % calculate value of function and jacobian 'xb'
%     error( 'jacobian calculation not implemented' );
    xb = zeros( numel( xg ), 7 ); % allocate memory
    
    
    % call subfunctions
    [ w, wb ] = HalfPlane( [ x(1:2) x(3) - pi/2 ] );
    [ g, gb ] = GaussianStripExp( [x(1:4) x(6:7)] );
    
    
    % forward calculation
    temp = ( ( xg-x(1) ).^2 + ( yg-x(2) ).^2 ) ./ x(4);
    temp0 = exp( -temp );
    tempb = -( w .* temp0 .* x(5) ./ x(4) );

    % calculate contribution of subfunctions to -jacobian
    gb = gb .* repmat( (1-w) .* x(5), 1, 5 );
    wb = wb .* repmat( ( temp0 - g ) .* x(5), 1, 3 );
    
    % add contributions to -jacobian
    xb(:,1) = 2.0 .* (xg-x(1)) .* tempb - gb(:,1) - wb(:,1);
    xb(:,2) = 2.0 .* (yg-x(2)) .* tempb - gb(:,2) - wb(:,2);
    xb(:,3) = - gb(:,3) - wb(:,3);
    xb(:,4) = temp .* tempb - gb(:,4);
    xb(:,5) = - ( w .* temp0 + (1-w) .* g );
    xb(:,6) = gb(:,5);
    % calculation of function value
    f = - x(5) .* xb(:,5);
    
  end

end