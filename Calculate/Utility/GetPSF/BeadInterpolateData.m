function objects = BeadInterpolateData( obj, params )
%INTERPOLATEDATA uses the data gained by fitting to calculate further useful
%details of the objects. The additional values are stored as new fields inside
%the 'objects' struct.
% arguments:
%   obj       the input objects array
%   img       the original grey version of the image
%   params    the parameter struct
% results:
%   objects   the output objects array
  
  global Data;
  
  % run through all objects
  obj_id = 1;
  while obj_id <= numel(obj)
    
    if isempty( obj(obj_id).p ) % empty objects have to be ignored
      obj(obj_id) = [];
      continue
    end
    
    % estimate total length, center of object and interpolate additional data
    if numel( obj(obj_id).p ) <= 1 % point object
      params.scale = Data.Input.General.PixelSize;
       
      objects.center_x(1,obj_id) = single( double(obj(obj_id).p(1).x(1)) * params.scale );
      objects.center_y(1,obj_id) = single( double(obj(obj_id).p(1).x(2)) * params.scale );
      objects.com_x(:,obj_id) = single( [obj(obj_id).p(1).x(1).value; obj(obj_id).p(1).x(1).error] * params.scale );
      objects.com_y(:,obj_id) = single( [obj(obj_id).p(1).x(2).value; obj(obj_id).p(1).x(2).error] * params.scale );
      objects.orientation(:,obj_id) = single( [0; 0]); 
      objects.length(:,obj_id) = single( [0; 0]);
      objects.width(:,obj_id) = double(obj(obj_id).p(1).w(1)) * params.scale;
      objects.cods(:, obj_id) = double(obj(obj_id).p(1).CoD);
    end
    

    % step to the next object
    obj_id = obj_id + 1;
    
  end % of running through all objects
  
  % make sure the structure is created, even if no object exists
  if numel( obj ) == 0
    objects = struct( 'center_x', {}, 'center_y', {}, 'com_x', {}, ...
      'com_y', {}, 'height', {}, 'width', {}, 'orientation', {}, ...
      'length', {}, 'data', {}, 'time', {}, 'radius', {}, 'cods', {});
  end
  
end
