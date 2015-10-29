function objects = InterpolateData( obj, img, params )
%INTERPOLATEDATA uses the data gained by fitting to calculate further useful
%details of the objects. The additional values are stored as new fields inside
%the 'objects' struct.
% arguments:
%   obj       the input objects array
%   img       the original grey version of the image
%   params    the parameter struct
% results:
%   objects   the output objects array

  error( nargchk( 3, 3, nargin ) );
  
  global Data Config Error;
  
  % run through all objects
  obj_id = 1;
  while obj_id <= numel(obj)
    
    if isempty( obj(obj_id).p ) % empty objects have to be ignored
      obj(obj_id) = [];
      continue
    end
    
    % estimate total length, center of object and interpolate additional data
    if numel( obj(obj_id).p ) <= 1 % point object
       obj(obj_id) = [];
       continue;
    else % elongated object     
     
      params.scale = Data.Input.General.PixelSize;
      numpoints = numel(obj(obj_id).p);

      %Fill unnecessary stuff
      objects.length(:,obj_id) = single( [0; 0] );
      objects.com_x(:,obj_id) = single( [0; 0] );
      objects.com_y(:,obj_id) = single( [0; 0] );
      
      % estimate orientation
      orientation = atan2( obj(obj_id).p(end).x(2) - obj(obj_id).p(1).x(2), ...
                    obj(obj_id).p(end).x(1) - obj(obj_id).p(1).x(1) );
      objects.orientation(:,obj_id) =  single( [orientation.value; orientation.error] );
        
      %Calculate widths
      widths_temp = cell(1,numpoints);
      for i3 = 1:numpoints
        widths_temp{i3} = double_error(obj(obj_id).p(i3).w(1).value, obj(obj_id).p(i3).w(1).error);
      end
      width = sum( [widths_temp{:}] ) ./ numpoints * params.scale;   
      objects.width(:,obj_id) = single( [width.value; width.error] );
      
      height = sum( [ obj(obj_id).p.h ] ) ./ numpoints;
      objects.height(:,obj_id)  = single( [height.value; height.error] );

      background = sum( [ obj(obj_id).p.b ] ) ./ numpoints;
      objects.background(:,obj_id)  = single( [background.value; background.error] );
      
      objects.cods(:,obj_id)  = [double( obj(obj_id).p(1).r ), double( obj(obj_id).p(end).r )];
      
      % Save additional data:
      % preallocating
      pos = [obj(obj_id).p(:)]; 
      pos = [pos.x];
      pos = pos(:).value;
      x = pos(1:2:end)'; %<< array containing the x-positions
      y = pos(2:2:end)'; %<< array containing the y-positions
      len = sqrt( (x-x(1)).^2 + (y-y(1)).^2);
      
      % determine center of object
      objects.center_x(1,obj_id) = single(x(round(numpoints/2)));
      objects.center_y(1,obj_id) = single(y(round(numpoints/2)));
      
      % calculate background, amplitude and width
      back = double( [ obj(obj_id).p.b ] );
      ampli = double( [ obj(obj_id).p.h ] );
      sigma = double( [ widths_temp{:} ] );

      % save points in final data struct
      objects.data{obj_id} = { single( [x'*params.scale y'*params.scale len'*params.scale sigma'*params.scale ampli' back'] ) ...
                              obj(obj_id) }; %TODO Check if it will work like this
      
    end % if object is pointlike or elongated

    % step to the next object
    obj_id = obj_id + 1;
    
  end % of running through all objects
  
  % make sure the structure is created, even if no object exists
  if numel( obj ) == 0
    objects = struct( 'center_x', {}, 'center_y', {}, 'com_x', {}, ...
      'com_y', {}, 'height', {}, 'width', {}, 'orientation', {}, ...
      'length', {}, 'data', {}, 'time', {}, 'radius', {});
  end
  
end
