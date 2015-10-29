function [ model, x0, dx, lb, ub ] = getParameter( model, data )
  global fit_pic
  
  % calculate position in region of interest
  c = double( model.guess.x - data.offset );

  % fill in missing parameters
  if isempty( model.guess.w )
%     [ width, height ] = GuessObjectData( c, [0 pi/2 pi 3*pi/2], data );
%     width = 2*width^2;
%     model.guess.w =  [ width width 0 ];
%     
%     if isempty( model.guess.h )
%       model.guess.h = height;
%     end
    model.guess.w = [ 5.0 5.0 ];
  end
  if length(model.guess.w)<3
    model.guess.w = [ model.guess.w model.guess.w 0.0 ];
  end
      
%   else
    if isempty( model.guess.h ) || isnan( model.guess.h )
      model.guess.h = abs(interp2( fit_pic, c(1), c(2), '*nearest' ) - double( data.background ));
    else
    model.guess.h = abs(model.guess.h - double( data.background ));
  end
%   end
  
  % setup parameter array
  %    [ X  Y           Orientation     PSF 	Sigma_along            Height           ]
  x0 = [ c(1:2)         model.guess.o   model.guess.w(1:2)           model.guess.h    ];
  dx = [ 1  1           pi/180          model.guess.w(1:2)/10        model.guess.h/10 ];
  lb = [ 1  1           0               0  0                         0                ];
  ub = [ data.rect(3:4) 2*pi            Inf Inf                      model.guess.h*10 ];
end