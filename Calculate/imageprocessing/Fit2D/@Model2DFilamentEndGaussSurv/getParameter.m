function [ model, x0, dx, lb, ub ] = getParameter( model, data )
  global fit_pic Config
  
  % calculate position in region of interest
  c = double( model.guess.x - data.offset );
  
  % fill in missing parameters
  if numel( model.guess.w ) < 2
    if isempty( model.guess.w )
      model.guess.w = [5.0 5.0];
    else
      model.guess.w = [model.guess.w model.guess.w];
    end
  end
  if isempty( model.guess.l )
     model.guess.l = 5.0;
  end
  if isempty( model.guess.h ) || isnan( model.guess.h )
    model.guess.h = abs(interp2( fit_pic, c(1), c(2), '*nearest' ) - double( data.background ));
  else
    model.guess.h = abs(model.guess.h - double( data.background ));
  end
  
  
  % setup parameter array
  %    [ X  Y           Orientation           Sigma_PSF  Sigma_PF    Height          ]
  x0 = [ c(1:2)         model.guess.o         model.guess.w(1:2)     model.guess.h   ];
  dx = [ 1  1           0.1                   model.guess.w(1:2)/10  model.guess.h/10];
  lb = [ 1  1           model.guess.o - pi/2  [0 0]                  model.guess.h/10];
  ub = [ data.rect(3:4) model.guess.o + pi/2  10*model.guess.w(1:2)  model.guess.h*10];

end