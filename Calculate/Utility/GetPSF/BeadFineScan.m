function objects = BeadFineScan( objects, params )
%FINESCAN processes the rough data of objects with the help of fitting. It tries
%to increase the accuracy of the parameters determined in the previous step
%while also determing some new properties and estimating errors
%
% arguments:
%   objects   the objects array
%   params    the parameter struct
% results:
%   objects   the extended objects array



  global pic; %<< load picture from global scope
  global Config;

  error( nargchk( 2, 2, nargin ) );
  

  FIT_AREA_FACTOR = 2 * 1;%params.reduce_fit_box; %<< factor determining the size of the area used for fitting
  params.fit_size = FIT_AREA_FACTOR * params.object_width;
  
  % process the remaining easy points
  objects = fitRemainingPoints( objects, params );
  
end

function objects = fitRemainingPoints( objects, params )
%FITREMAININGPOINTS processes unfitted parts of the obejcts
% arguments:
%   objects   the objects array
%   params    the parameter struct
% results:
%   objects   the extended objects array

%   'Remaining points'
  error( nargchk( 2, 2, nargin ) );

  global Config;
  
  k = 1;
  while k <= numel(objects) % run through all objects
    % determine which kind of object we have    
    if numel( objects(k).p ) == 1 % single point
        [ data, CoD ] = Fit2D( params.bead_model_char, objects(k).p, params );
        if CoD > params.min_cod % fit went well
          data.CoD = CoD;
          objects(k).p = data;
          k = k+1;
        else % bad fit result
          objects(k).p = [];
          continue;
        end
    else
      objects(k).p = [];
    end
  end % of run through all objects
end