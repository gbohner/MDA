function [ model, x0, dx, lb, ub ] = getParameter( model, data )
  global fit_pic
  
  % calculate position in region of interest
  c = double( model.guess.x - data.offset );

  % fill in missing parameters
  if isempty( model.guess.w )
    model.guess.w = [ 5.0 5.0 ];
  end
  
  if numel(model.guess.w) == 1
    model.guess.w = [model.guess.w model.guess.w];
  end
  
  if isempty(model.guess.l)
    model.guess.l = 0.1;
  end
      
%   else
  if isempty( model.guess.h ) || isnan( model.guess.h )
    model.guess.h = abs(interp2( fit_pic, c(1), c(2), '*nearest' ) - double( data.background ));
  else
    model.guess.h = abs(model.guess.h - double( data.background ));
  end
%   end
  
  % setup parameter array
  %    [ X  Y           Orientation     PSF 	Sigma_along            Height             Lattice Int]
  x0 = [ c(1:2)         model.guess.o   model.guess.w(1:2)           model.guess.h      model.guess.l   ];
  dx = [ 1  1           pi/180          model.guess.w(1:2)/10        model.guess.h/10   model.guess.l/10];
  lb = [ 1  1           0               0  0                         0                  0               ];
  ub = [ data.rect(3:4) 2*pi            Inf Inf                      model.guess.h*10   0.9             ];
end