function model = Model2DComet( guess )
  if ~isfield( guess, 'x' )
    guess.x = [];
  end
  if ~isfield( guess, 'w' )
    guess.w = [];
  end
  if ~isfield( guess, 'h' )
    guess.h = [];
  end
  if ~isfield( guess, 'b' )
    guess.b = [];
  end
  if ~isfield( guess, 'o' )
    guess.o = [];
  end
  if ~isfield( guess, 'lambda' )
    guess.lambda = [];
  end
  if ~isfield( guess, 'mtLattice' )
    guess.mtLattice = [];
  end
  if numel(guess.o)<1
      guess.o(1) = pi/4;
  end

  % check guesses
  if numel( guess.x ) < 2 || numel( guess.o ) < 1
    error( 'MPICBG:FIESTA:notEnoughParameters', ...
           'A position and an orientation have to be given for a comet model.' );
  end

  model = struct( 'guess', {guess} );

  model = class( model, 'Model2DComet' );
end