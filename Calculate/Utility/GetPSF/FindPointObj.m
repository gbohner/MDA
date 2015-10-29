function [ objects, params ] = FindPointObj( pic, bw )
%ROUGHSCAN tries to locates objects roughly. This is done using a thresholded
%(black and white) image and some image processing. The results are inaccurate
%position coordinates for points and a list of coordinates for elongated
%objects, roughly descibing the spatial configuration in the image.
%
% arguments:
%   objects   the objects array
%   params    the parameter struct
% results:
%   objects   the extended objects array

 
  global roughpic Config

  roughpic = double(pic);
  
  %Max 1 bead per region else don't take
  params.max_beads_per_region = 1;
  
  % estimate background level
  params.background = mean( roughpic( bw == 0 & ~isnan(roughpic) ) ) ;
  
  % calculate estimated object width
  params.fwhm_estimate = Config.settings.threshold.ThreshParams.Deconv.fwhm;
  params.object_width = params.fwhm_estimate / (2*sqrt(2*log(2)));

  % get statistical data of the different regions
  bw_stats = regionprops( logical(bw), 'Area', 'BoundingBox', 'Centroid', 'Image' );  
  
  % setup struct for the final object data
  objects = struct( 'p', {} );
  
  %%----------------------------------------------------------------------------
  %% SCAN BLACK AND WHITE IMAGE
  %%----------------------------------------------------------------------------

  % determine which areas should be scanned
  if ~isfield( params, 'scanareas' )
    params.scanareas = 1:numel(bw_stats);
  end
  
  % run through all regionprobs areas
  for area = params.scanareas

    % initialize variable containing new objects
    new_obj = [];
    
    new_obj = FindPointObjects( bw_stats(area), params );   

    if ~isempty( new_obj ) % new objects have been found
      % add found objects to list
      objects(end+1:end+numel(new_obj)) = new_obj;
    end
    
  end % of loop through all regionprob objects
  
  %%----------------------------------------------------------------------------
  %% CHECK OBJECT DATA
  %%----------------------------------------------------------------------------

  % make sure, only the requested features are found
  k = 1;
  while k <= numel( objects )
    if  numel( objects(k).p ) > 1 
      % delete wrong object
      objects(k) = [];
    else
      k = k + 1;
    end
  end

% % % % % % % % % % % % % % % % % % % %  
% %Calculate the background
background = imopen(roughpic ,strel('disk',15));
for i74 = 1:numel(objects)
      obp = objects(i74).p;
      for i741 = 1: numel(obp)
        obp(i741).b = background(round(obp(i741).x(1)),round(obp(i741).x(2)));
      end
      objects(i74).p = obp;
end
% % % % % % % % % % % % % % % % % % % % %   
  
  % delete global variables to clean up
  clear global bw;
  
end

function objects = FindPointObjects( region_stats, params )
%FINDOBJECT tries to find beads at the given area in the bw image. This is
%achieved by looking for local maxima in the grey image corresponding to the
%region
%
% arguments:
%   region_stats  the result of the regionprobs function for the area to be
%                 scanned
%   params        the parameters struct
% results:
%   objects       a struct with the object data

  error( nargchk( 2, 2, nargin ) );

  % search local maximas in the region, to find possibly many close-lying
  % objects
  global roughpic %<< load grey image
  
  EMPTY_POINT = struct( 'x', {}, 'o', {}, 'w', {}, 'h', {}, 'r', {}, 'b', {}, 'l', {} );
  
  % crop orginal image with same dimensions as binary one
  sub_pic = imcrop( roughpic, region_stats.BoundingBox - [ 0 0 1 1 ] );
  sub_pic_bw = region_stats.Image;
  sub_pic = wiener2(sub_pic);
%   sub_pic = filter2( h, sub_pic, 'same' );
%   sub_pic = medfilt2( sub_pic );

% find the local maxima area in the right area
  pic_max = imregionalmax( sub_pic .* double( sub_pic_bw ), 8 );
  % find center of the disjoint areas
  regions = regionprops( logical( pic_max ), 'Centroid' );
  
  % sort maxima by there intensity
  maximas = zeros( numel(regions), 3 );
  for k = 1 : numel(regions)
    maximas(k,:) = [ regions(k).Centroid ...
        sub_pic( round( regions(k).Centroid(2) ), round( regions(k).Centroid(1) ) ) ];
  end
  maximas = sortrows( maximas, -3 );
  
  %delete maximas with ratio to brightest maximum smaller than 0.1
  if size(maximas,1)>1
    maximas((maximas(:,3)-params.background)<0.1*(maximas(1,3)-params.background),:)=[]; 
  end
  
  % choose the right maxima(s)
  if params.max_beads_per_region > 1 && size(maximas,1) > 1 % many maxima in the region    
      
    % remove maximas, which are close to each other
    idx = getClusters( maximas, 3, 2 ); % find close points
    for i = unique( idx )
      f = find( idx == i );
      maximas( f(2:end), 3 ) = -1;
    end
    maximas( maximas(:,3) < 0, : ) = [];
    
    % take the brigthes maximas
    num_maximas = min( size(maximas,1), params.max_beads_per_region );
    objects = repmat( struct( 'p', EMPTY_POINT ), 1, num_maximas ); % preallocate
    for i = 1 : num_maximas
      objects(i).p(1).x = maximas(i,1:2) + region_stats.BoundingBox(1:2) - 0.5;
      objects(i).p(1).w = ( params.fwhm_estimate / 2.77258872223978 )^2;
      objects(i).p(1).b = NaN;
    end
    
  else % only one point in region or only one point requested
    objects(1).p = EMPTY_POINT;
    objects(1).p(1).x = region_stats(1).Centroid;    
    objects(1).p(1).w = ( params.fwhm_estimate / 2.77258872223978 )^2;
    objects(1).p(1).b = NaN;
  end

end

