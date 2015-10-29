function [ f, xb ] = evaluate( model, x )

  global xg yg; % load roi grids from global scope

  p = model.img_size / 2 + 0.5 + x(1) * [ -sin( x(2) ) cos( x(2) ) ];
  
  % calculate distance on ray
  t = ( p(1) - xg ) .* cos(x(2)) - ( yg - p(2) ) .* sin(x(2));

  % calculate orientated distance to ray
  d = ( p(1) - xg ) .* sin(x(2)) + ( yg - p(2) ) .* cos(x(2)) + ...
      x(3) .* t.^2; % the last term provides the quadratic nature

  if nargout == 1 % calculate value of function

    f = x(5) * exp( -0.5* d.^2 ./ (x(4).^2) );
  
  else % calculate value of function and jacobian 'xb'
    
    % allocate memory
    xb = zeros( prod( model.img_size ), 5 ); 
    pb = zeros( prod( model.img_size ), 2 );

    temp = d.^2 ./ (x(4).^2); % argument of exponential
    xb(:,5) = -exp(-0.5*temp);
    f = -x(5) * xb(:,5); % function value
    tempb = -0.5* f ./ (x(4).^2);
    db = 2 .* d .* tempb;
    
    xb(:,4) = temp .* tempb;
    xb(:,3) = -t.^2 .* db;

    tb = 2 * x(3) .* t .* db;
    pb(:,1) = sin(x(2)) * db;
    pb(:,2) = -cos(x(2)) * db;
    
    pb(:,1) = pb(:,1) + cos(x(2)) .* tb;
    xb(:,1) = pb(:,1) .* sin(x(2)) - pb(:,2) .* cos(x(2));
    
    pb(:,2) = pb(:,2) + sin(x(2)).*tb;
    xb(:,2) = ( (yg-p(2)) .* sin(x(2)) - (p(1)-xg) .* cos(x(2)) ) .* db ...
            + ( (yg-p(2)) .* cos(x(2)) + (p(1)-xg) .* sin(x(2)) ) .* tb ...
            + (  pb(:,2)  .* sin(x(2)) +  pb(:,1)  .* cos(x(2)) ) .* x(1);

  end
end