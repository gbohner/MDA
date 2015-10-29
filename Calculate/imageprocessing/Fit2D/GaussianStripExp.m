function [ f, xb ] = GaussianStripExp( x, offset, sf )
%GAUSSIANSTRIP creates an image with a gaussian wall of height 1.0 and
%same dimensions as the grids 'xg' and 'yg' with an offset for the
%lattice-binding.
% arguments:
%   x     input variables for the ray describing the gaussian:
%            1  x-position of the start point of the ray
%            2  y-position of the start point of the ray
%            3  angle between this ray and the x-axis
%            4  width of the gaussian
%            5  height of the gaussian
%            6  the lambda of exponential decrease
%            7  the relative lattice intensity [0-1]
% results:
%   f     the returned grey image
%   xb        the jacobian of the image with respect to the input variable x
%             this is optional and only calculated, if requested

  global xg yg; % load roi grids from global scope
  
  rad = -x(3);
  sM = [sf * cos(rad)^2 + 1 * sin(rad)^2,  1 * cos(rad) * sin(rad) - sf * cos(rad) * sin(rad) ;...
                 1 * cos(rad) * sin(rad) - sf * cos(rad) * sin(rad), 1 * cos(rad)^2 + sf * sin(rad)^2 ];
  
  baseintensity =exp( -((sM(1,1)*(offset * cos(x(3))) + sM(1,2) * (offset * sin(x(3)))).^2  + ...
                  (sM(2,1)*(offset * cos(x(3))) + sM(2,2) * (offset * sin(x(3)))).^2 ) / x(4)^2 ) ...
                  - x(7);
  x(3) = -rad;
                
  x(1) = x(1) + offset * cos(x(3));
  x(2) = x(2) + offset * sin(x(3));
  
  % calculate orientated distance to ray
  d = ( yg - x(2) ) .* cos(x(3)) + ( x(1) - xg ) .* sin(x(3));
  
  % calculate ray point distance from origin
  dr = ( yg - x(2) ) .* cos(x(3)- pi/2) + ( x(1) - xg ) .* sin(x(3) - pi/2);
  
  if nargout == 1
    % use this for gaussian

%     f = exp( - d.^2 ./ x(4) );
    f = exp( -0.5* d.^2 ./ x(4)^2 ).*(baseintensity*exp(-x(6)*abs(dr))+x(7));
  else
    xb = zeros( numel(xg), 5 ); % preallocate memory
    
    % calculate intermediate variables and value of function  
    f = exp( -0.5* d.^2 ./ x(4) ).*exp(-x(6)*abs(dr));
    
%     dd = - (2*d.*exp( (d.^2 - x(4).*x(5).*abs(dr))./x(4)))./x(4);
%     drd = (dr>=0).*(x(5).*(-exp(-d.^2./x(4)-x(5)*dr))) + ...
%           (dr<0).*(x(5).*(exp(-d.^2./x(4)+x(5)*dr)));
    
    % calculate jacobian
    xb(:,1) = (x(5)*cos(x(3)) - 1/x(4) * 2 * sin(x(3)) .* d) .* exp(-d.^2 / x(4) - x(5) .* (( yg - x(2) ) .* sin(x(3)) - ( x(1) - xg ) .* cos(x(3)) + 0.5));
    xb(:,2) = (x(5)*sin(x(3)) + 1/x(4) * 2 * cos(x(3)) .* d) .* exp(-d.^2 / x(4) - x(5) .* (( yg - x(2) ) .* sin(x(3)) - ( x(1) - xg ) .* cos(x(3)) + 0.5));
    xb(:,3) = - 1/x(4) * 2 * (d.*(dr-0.5) -x(5)*(d-0.5)) .* exp(-d.^2/x(4) - x(5) .* (( yg - x(2) ) .* sin(x(3)) - ( x(1) - xg ) .* cos(x(3)) + 0.5));
    xb(:,4) = (d.^2.*exp(-  d.^2 / x(4) - x(5).*(( yg - x(2) ) .* sin(x(3)) - ( x(1) - xg ) .* cos(x(3)) + 0.5)) )./(x(4)).^2;
    xb(:,5) = ((x(1)-xg)*cos(x(3)) - (yg - x(2))*sin(x(3)) - 0.5).*exp(- ( d.^2 / x(4) - x(5).*(( yg - x(2) ) .* sin(x(3)) - ( x(1) - xg ) .* cos(x(3)) + 0.5)));
    
  end
end