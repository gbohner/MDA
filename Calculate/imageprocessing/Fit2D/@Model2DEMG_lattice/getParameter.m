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
  if isempty( model.guess.h ) || isnan( model.guess.h )
    model.guess.h = abs(interp2( fit_pic, c(1), c(2), '*nearest' ) - double( data.background ));
  else
    model.guess.h = abs(model.guess.h - double( data.background ));
  end  
  if isempty( model.guess.l )
    model.guess.l = [30 model.guess.h/10];
  end
  
  
  % setup parameter array
  %    [ X  Y           Orientation     Sigma_PSF  w         Height (A)       Tau    Lattice]
  x0 = [ c(1:2)         model.guess.o   model.guess.w(1:2)   model.guess.h    model.guess.l(1:2)      ];
  dx = [ 1  1           1e-8            [0.1 0.1]            10               [0.1 model.guess.h/100] ];
  lb = [ 1  1           0               [1 1]                1                [0.1 0]                 ];
  ub = [ data.rect(3:4) 6.3             [50 50]              Inf              [Inf 100000]            ];

end