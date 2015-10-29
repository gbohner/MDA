function objects = FineScan( objects, params )
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
  

  FIT_AREA_FACTOR = 4 * 1;%params.reduce_fit_box; %<< factor determining the size of the area used for fitting
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
    if numel( objects(k).p ) == 2 % small filament
      if isnan( double(objects(k).p(1).b) ) || isnan( double(objects(k).p(2).b) ) % has not been fitted
        guess = struct( 'x', [ objects(k).p(1).x ; objects(k).p(2).x ] );
        [ data, CoD ] = Fit2D( 't', guess, params );
        if CoD == -11 % filament ends lie exactly on top of each other
          objects(k).p(2) = []; % delete second point
          continue; % reprocess object
        elseif norm(data.x(1,1:2)'-data.x(2,1:2)')<mean(data.w) % filament ends are too close together that they could not be resolved
          objects(k).p(2) = []; % delete second point
          continue; % reprocess object            
        elseif CoD > params.min_cod % fit went well
          objects(k).p(1) = data;
          objects(k).p(1).x = data.x(1,1:2);
          objects(k).p(1).o = mod( data.o + pi, 2*pi );
          objects(k).p(2) = data;
          objects(k).p(2).x = data.x(2,1:2);
          objects(k).p(2).o = mod( data.o + pi, 2*pi );
        else % bad fit result
          objects(k).p(2) = [];
          objects(k).p(1) = [];
          Log( [ 'small filament has been disregarded: ' CoD2String( CoD ) ], params );
          continue;
        end
      end
    end
    if numel( objects(k).p ) > 2 % elongated object
%       'Tracking elongated object'
      pos_vector = double([objects(k).p.x]);
      pos_x = pos_vector(1:2:end);
      pos_y = pos_vector(2:2:end);
      length_vector = zeros(1,numel( objects(k).p ));
      for n = 2 : numel( objects(k).p )
        length_vector(n) = length_vector(n-1) + sqrt((pos_x(n-1) - pos_x(n)).^2 + ...
                                                     (pos_y(n-1) - pos_y(n)).^2);
      end

      cluster_points = [];
      fixed_points = [1 cluster_points numel( objects(k).p )];
      fit_points = [];
      for n = 2:numel(fixed_points)
        if fixed_points(n-1) == fixed_points(n)
          fit_points = [fit_points fixed_points(n)];
        else
          fit_points = [fit_points fixed_points(n-1)];
          num_mp = round( (length_vector(fixed_points(n)) - length_vector(fixed_points(n-1))) / abs((1.5 * params.fit_size) - 1) );
          if num_mp > 0
            length_mp = (length_vector(fixed_points(n)) - length_vector(fixed_points(n-1))) / (num_mp + 1);
            for m = 1: num_mp
              [~,t] = min(abs( length_vector - length_vector(fixed_points(n-1)) - m*length_mp ));
              fit_points = [fit_points t];
            end
          end
          fit_points = [fit_points fixed_points(n)];
        end
      end
      fit_points(ismember(fit_points,cluster_points)) = [];
          
      fit_points = sort(fit_points);
      
      for n = fit_points       

        p = objects(k).p(n);
        p.x = double( p.x );
        p.o = double( p.o );  
        p.w = double( p.w );
        p.h = double( p.h );        
        p.r = double( p.r );
        p.b = double( p.b );            
        
        params.min_cod = 0;
        if n == 1 % start point
%           if ~strcmp(Config.settings.mt_end_model,'u')
            p.o = p.o - pi;
%           end
          
          [ data, CoD ] = Fit2D( Config.settings.mt_end_model, p, params );
          data.r = double_error(CoD,0);
          if CoD > params.min_cod % fit went well
%             if ~strcmp(Config.settings.mt_end_model,'u')
                data.o = data.o - pi;
%             end
            objects(k).p(n) = data;
          else % bad fit result
            Log( [ 'Point has been disregarded: ' CoD2String( CoD ) ], params );
            %delete from fit_point members
            m = n;
            fit_points(fit_points == m) = 0;
            continue;
          end
          
        elseif n == numel( objects(k).p ) % end point
%           if strcmp(Config.settings.mt_end_model,'u')
%             p.o = p.o - pi;
%           end
          [ data, CoD ] = Fit2D( Config.settings.mt_end_model, p, params );
          data.r = double_error(CoD,0);
          if CoD > params.min_cod % fit went well
%             if strcmp(Config.settings.mt_end_model,'u')
%                 data.o = data.o - pi;
%             end
            objects(k).p(n) = data;
          else % bad fit result
            Log( [ 'Point has been disregarded: ' CoD2String( CoD ) ], params );
            %delete from fit_point members
            m = n;
            fit_points(fit_points == m) = 0;
            continue;
          end
        
        else % middle point
          
          p.o = p.o + pi;
          [ data, CoD ] = Fit2D( 'm', p, params );
          data.r = double_error(CoD,0);
          if CoD > params.min_cod % fit went well
            data.o = data.o - pi;
            objects(k).p(n) = data;
          else % bad fit result
            %delete from fit_point members
            m = n;
            fit_points(fit_points == m) = 0;
          end
         
        end % of run through all points
      end
      
      %delete points that were not fitted
      del_list = 1:numel( objects(k).p );
      del_list(ismember(del_list,fit_points)) = 0;
      objects(k).p(del_list ~= 0)=[];
      
      %reconfigure non-fitted 'fit_points'
      
      
    end % of choice, if its an elongated object
    % delete empty objects!
    if isempty( objects(k).p )
      objects(k) = [];
    else
      k = k + 1; % step to next object
    end
  end % of run through all objects
end