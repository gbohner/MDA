function [ model, x0, dx, lb, ub ] = getParameter( model, data )
  global fit_pic
  
  % calculate position in region of interest
  c = double( model.guess.x - data.offset );
  
  % fill in missing parameters
  if isempty( model.guess.w )
    model.guess.w = 5.0;
  end
  if isempty( model.guess.h ) || isnan( model.guess.h )
    model.guess.h = abs(interp2( fit_pic, c(1), c(2), '*nearest' ) - double( data.background ));
  else
    model.guess.h = abs(model.guess.h - double( data.background ));
  end
  if isempty( model.guess.lambda )
      model.guess.lambda = 0.25;
  end
  if isempty( model.guess.mtLattice)
    model.guess.mtLattice = 0.3;
  end
  
  
  % setup parameter array
  %    [ X  Y           Orientation           Width             Height              Lambda                  mtLattice]
  x0 = [ c(1:2)         model.guess.o         model.guess.w     model.guess.h       model.guess.lambda      model.guess.mtLattice ];
  dx = [ 1  1           0.01                  model.guess.w/10  model.guess.h/10    0.001                   0.01                  ];
  lb = [ 1  1           model.guess.o - pi    0                 model.guess.h/10    0                       0                     ];
  ub = [ data.rect(3:4) model.guess.o + pi    40                model.guess.h*10    4                       0.9                   ];

end