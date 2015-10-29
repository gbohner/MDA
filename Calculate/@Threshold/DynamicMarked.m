function [ binaryImage ] = DynamicMarked(obj)
%DYNAMICMARKED Returns precise binary image of given microtubules
%   Based on previous tracking data and various assumptions about MT growth and dynamics, 
%   it finds the pixels in the image belonging to a user-marked MT

global Config Data Gui

%Finding current frame
frame = Data.Track.current.frame;
num = validFils(); %Determining all marked MTs on current frame

%score holds binary image for current MT
score = zeros(size(obj.output));
%binaryImage holds binary image for all MTs (logical sum of scores)
binaryImage = zeros(size(obj.output));

%Going through all marked MTs on current frame, calculating binary image separately for each
for n = num
  %score holds BW image for current MT
   score = zeros(size(obj.output));
   
   %Based on previous frames' track, creating a dense line of points to use for tracking this frame
   Data.Track.ToTrack{n}.points = interp_points(Data.Track.ToTrack{n}.points);
   
   %Checking if previously tracked object is resembling marked seed.
   %If so then using seed's point for next step (to avoid bad fits leading to curved MTs)
   num_points = 1.*size(Data.Track.ToTrack{n}.points,1);
   if num_points < size(Data.Track.ToTrack{n}.points_seed,1)
      Data.Track.ToTrack{n}.points = Data.Track.ToTrack{n}.points_seed;
   end
      
   %Setting parameters used for finding the ends of the MT
   %These parameters also set the range for where to look for the end (big steps not allowed)
   num_fitpoints = floor(min(num_points-1, max(num_points./4.0, 4))); %at the ends to extrapolate
   neigh = Config.tracking.advanced.DynamicMarked.neigh; %Neighborhood for averaging filter
   avg_growth = Config.tracking.advanced.DynamicMarked.avg_growth; %in pixel
   lng = Config.tracking.advanced.DynamicMarked.lng; %min 5; hard cap for maximum MT growth in pixels
   variate_num = Config.tracking.advanced.DynamicMarked.variate_num; %sideway steps to counter drifting of MTs
   variate_step = Config.tracking.advanced.DynamicMarked.variate_step; % pixel, will be multiplied by variate_num
   dseed_threshold = Config.tracking.advanced.DynamicMarked.dseed_threshold; % in pixel, end distance threshold from seed
   dseed_threshold_vclose = Config.tracking.advanced.DynamicMarked.dseed_threshold_vclose; % in pixel, end distance threshold from seed 
   thresh_cat_value = Config.tracking.advanced.DynamicMarked.thresh_cat_value;  %Intensity drop (AU) that means a catastrophe is happening
   thresh_end = Data.Track.ToTrack{n}.thresh; % Minimum threshold value for Int_MTend / Int_Background.
   
   
   %Find the brightest points perpendicularly along the marked seed. Used to counter drifting.
   Data.Track.ToTrack{n}.points_seed = ...
      variate_points(Data.Track.ToTrack{n}.points_seed, obj.output, variate_num, variate_step);
     
   %Find the brightest points perpendicularly along the marked MT. Used to counter drifting.
   Data.Track.ToTrack{n}.points = ...
      variate_points(Data.Track.ToTrack{n}.points, obj.output, variate_num, variate_step);
  
   %Extrapolate points along the microtubule at the ends to find the new end after growth.
   warning('off','all');
   ext_points = extrapolate(lng);
   warning('on','all');
   
   %Create a 1D dataset of MT intensities based on the marked points.
   lin_avg_values = get_avg_vals(ext_points, neigh);

   %Find points belonging to the current MT on the current frame based on previous data
   valid_points = markov_decision(ext_points,lin_avg_values,lng, avg_growth);
   
   %Make valid points white in the binary score pictures
   for i2 = 1:size(valid_points,1)
       try
        score(round(valid_points(i2,2)), round(valid_points(i2,1))) = 1;
       end
   end
   
   %Morphologically smooth the binary image
   score = bwmorph(score, 'dilate');
   score = bwmorph(score, 'close');
   score = bwmorph(score, 'diag');
   score = bwmorph(score, 'dilate');
   
   %Add the score image to binaryImage holding data for all marked MTs
   binaryImage = binaryImage + score;
end

%Modify binary image so that crossing MTs give value of 1 as well.
%This is return
binaryImage(binaryImage>1) = 1;


%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %Finds marked filaments that are to be tracked on current frame
   function n = validFils()
      n=[];
      for k = 1:numel(Data.Track.ToTrack)
         frames = Data.Track.ToTrack{k}.frames;
         if frames(1)<=frame && frame<=frames(2)
            n = [n k];
         end
      end
   end

  %Two-dimensinal linear interpolation
   function p_out = interp_points(p)
      p_out = [];
      for i1 = 1:size(p,1)-1
         points = linspace2d(p(i1,:),p(i1+1,:),max(2,floor(norm(p(i1+1,:)-p(i1,:)))));
         points = points(1:end-1,:);
         p_out = [p_out; points];
      end
      try
        p_out = [p_out; p(end,:)];
      end
   end

  %Two-dimensinal linear extrapolation
  %Returns extrapolated points and inner points as well
   function ext_points = extrapolate(lng)
      plus_x_data = Data.Track.ToTrack{n}.points(floor(end-num_fitpoints):end,1);
      if sum(diff(plus_x_data)) == 0
         Data.Track.ToTrack{n}.points(end,1) = Data.Track.ToTrack{n}.points(end,1) + 0.1;
      end
      plusend_fit = polyfit(Data.Track.ToTrack{n}.points(floor(end-num_fitpoints):end,1),...
                            Data.Track.ToTrack{n}.points(floor(end-num_fitpoints):end,2),...
                            1); %linear fit near plus end to extrapolate.
      plus_x_fit = polyfit((floor(num_points-num_fitpoints):num_points)',Data.Track.ToTrack{n}.points(floor(end-num_fitpoints):end,1),1);
         %linear fit to x values, use this to find out corresponding y values at both ends from other fits.                         
                         
      minus_x_data = Data.Track.ToTrack{n}.points(1:1+ceil(num_fitpoints),1);
      if sum(diff(minus_x_data)) == 0
         Data.Track.ToTrack{n}.points(1,1) = Data.Track.ToTrack{n}.points(1,1) - 0.1;
      end
      minusend_fit = polyfit(Data.Track.ToTrack{n}.points(1:1+ceil(num_fitpoints),1),...
                             Data.Track.ToTrack{n}.points(1:1+ceil(num_fitpoints),2),...
                             1); %linear fit near minus end to extrapolate.
      minus_x_fit = polyfit((1:1+ceil(num_fitpoints))',Data.Track.ToTrack{n}.points(1:1+ceil(num_fitpoints),1),1);
         %linear fit to x values, use this to find out corresponding y values at both ends from other fits.
         
      
         
      minus_x_points = polyval(minus_x_fit,-lng+1:0);
      minus_y_points = polyval(minusend_fit,minus_x_points);
      minus_points = [minus_x_points', minus_y_points'];
      
      plus_x_points = polyval(plus_x_fit,num_points+1:num_points+lng);
      plus_y_points = polyval(plusend_fit,plus_x_points);
      plus_points = [plus_x_points', plus_y_points'];
      
      ext_points = [minus_points; Data.Track.ToTrack{n}.points; plus_points];
   end

   %Returns 1D intensity values based on given points. 
   %2D averaging filter of size neigh used for smoothing
   function lin_avg_values = get_avg_vals(p, neigh, varargin)
      if isempty(varargin)
         val_im = obj.output;
      else
         val_im = varargin{1}.output;
      end
      lin_avg_values = zeros(size(p,1),1);
      for n1 = 1:size(lin_avg_values)
         p1 = round(p(n1,:));
         sum = 0;
         wrong = 0;
         for i1 = p1(1)-neigh : p1(1)+neigh 
            for j1 = p1(2)-neigh : p1(2)+neigh
               try
                  sum = sum + double(val_im(j1,i1));
                  %matlab's logical indexing for images 
                  %   is image(col,row) to reach value, thus I use (y,x) here.
               catch
                  wrong = wrong + 1;
               end
            end
         end
         lin_avg_values(n1) = sum / ( (2*neigh+1)^2 - wrong);
      end
            
   end

   %Find points belonging to the current MT on the current frame based on previous data
   function valid_points = markov_decision(p,val,lng,avg_growth)
     %Average background equals given Mean value of previously applied Wallis filter
     %TODO 
     avg_bg = Config.settings.threshold.ThreshParams.Wallis.args{1}.*1;
%       avg_bg = mean2(obj.output(obj.output<min(min(obj.output))*2));
      
      %Check if end point is close to seed; For both minus and plus ends
      x = Data.Track.ToTrack{n}.points_seed(:,1); %X coordinates of marked seed
      y = Data.Track.ToTrack{n}.points_seed(:,2); %Y coordinates of marked seed
      if Data.Track.ToTrack{n}.iscat(1) ~= 1 %if there's a catastrophe happening for at least 3 frames, it lets it continue
        dmin_minus = min(sqrt((x-p(lng+1,1)).^2 + (y-p(lng+1,2)).^2));
      else
        dmin_minus = Inf;
      end
      if Data.Track.ToTrack{n}.iscat(2) ~= 1 %if there's a catastrophe happening for at least 3 frames, it lets it continue
        dmin_plus =  min(sqrt((x-p(size(p,1)-lng,1)).^2 + (y-p(size(p,1)-lng,2)).^2));
      else
        dmin_plus = Inf;
      end
      
      %Finds the likely end points of the microtubule, handles catastrophes.
      try
        [t_minus, t_plus] = check_end();
      catch
          t_minus = lng+1;
          t_plus = size(p,1)-lng;
      end
      
      %Optimization functions for finding the most probable end points in all conditions
      f_tomax_minus = @(k)nocat_prob(k,avg_growth,'minus')*abs(val(t_minus-k)-avg_bg)/avg_bg;
      f_tomax_plus = @(k)nocat_prob(k,avg_growth,'plus')*abs(val(t_plus+k)-avg_bg)/avg_bg;
      
      %Scoring all possible end-points, choosing highest scorer as real one.
      k_vals = zeros(avg_growth+2,2);
      for k1 = -1:avg_growth
         try %in case there are less than 20 points
            k_vals(k1+2,1) = f_tomax_minus(k1);
            k_vals(k1+2,2) = f_tomax_plus(k1);
         end
      end
      [~, ind] = max(k_vals);
      ind = ind - 2;
      k_minus = ind(1) + (lng + 1 -t_minus) ;
      k_plus = ind(2) + (t_plus - lng - num_points) ;
      
      %After optimizations, returns all points belonging to the MT between the two most likely end-points
      valid_points = p(lng+1-k_minus:lng+num_points+k_plus,:);
      
      %Subfunction for optimization of end point
      function prob = nocat_prob(k,avg_growth,str)
         switch str
            case 'minus'
               dmin = dmin_minus;
               if abs(val(t_minus-k)) < thresh_end * avg_bg
                   prob = 0;
                   return
               end
               %Points close to seed (but not very close) get high prop.
%                dk = min(sqrt((x-p(t_minus-k,1)).^2 + (y-p(t_minus-k,2)).^2));
%                if abs(val(t_minus-k)) > 1.2 * avg_bg && dk < dseed_threshold_vclose && dk > 4
%                    prob = 3;
%                    return
%                end
            case 'plus'
               dmin = dmin_plus;
               if abs(val(t_plus+k)) < thresh_end * avg_bg
                   prob = 0;
                   return
               end
               %Points close to seed (but not very close) get high prop.
%                dk = min(sqrt((x-p(t_plus+k,1)).^2 + (y-p(t_plus+k,2)).^2));
%                if abs(val(t_plus+k)) > 1.2 * avg_bg && dk < dseed_threshold_vclose  && dk > 4
%                    prob = 3;
%                    return
%                end
         end         
         
         if dmin > dseed_threshold_vclose
            prob = normpdf(k,avg_growth,2)/0.1995; % = normpdf(0,0,2);
            prob = nthroot(prob,4);
         else
            prob = normpdf(k,avg_growth + 1,2)/0.1995; % = normpdf(0,0,2);
         end
      end
      
      %Finds a likely end point of the microtubule, handles catastrophes too.
      function [t_minus, t_plus] = check_end()
        %During marking returns just marked values for display
         if Gui.state.marking == 1 || Config.settings.trackCatastrophes == 0
            t_minus = lng + 1;
            t_plus = length(val)-lng;
            return;
         end
         
         myvals = zeros(2+Config.settings.lookahead,size(Data.Track.ToTrack{n}.points,1));
        %Load myvals with 1D values based on our points from previous, current and next frames
         for i1 = 1:2+Config.settings.lookahead
             myvals(i1,:) = get_avg_vals(Data.Track.ToTrack{n}.points,neigh,Data.Track.current.thr{i1});
         end
         
         %strip minus end of dark pixels
         add_t_minus = 0;
         while myvals(2,1)<avg_bg*thresh_end
            myvals = myvals(:,2:end);
            add_t_minus = add_t_minus + 1;
         end
         %strip plus end of dark pixels
         while myvals(2,end)<avg_bg*thresh_end
            myvals = myvals(:,1:end-1);
         end
         
         myvals_diff = diff(myvals);
         
         %Checks if a catastrophe is likely happening in current frame
         %If yes, then looks ahead in the next frames whether the intensity goes back up
         
         %Find indices of dark points, up to where catastrophe might have destroyed the MT (so they're dark)
         inds = find(myvals_diff(1,:)<thresh_cat_value);
         t_minus = 1;
         t_plus = size(myvals_diff,2);
         %From each such index, check if there's surely no bright tubulin parts (MT) further from seed
         for i4 = inds
            %check if catastrophe happened from minus end to i4
            valid_minus = 1;
            for j4 = i4:-1:1
               if myvals(2,j4) < avg_bg*thresh_end
                  continue;
               end
               %If there's a bright area, then probably it's no catastrophe, disregard.
               if myvals_diff(1,j4) > abs(thresh_cat_value)/2 || ...
                     sum(myvals_diff(2:end,j4)>abs(thresh_cat_value)/2) > 0 || ...
                     myvals(2,j4) > avg_bg*(1+1.5*(thresh_end-1))
                  valid_minus = 0;
                  break;               
               end
            end
            %If it's a valid end-point, set minus end's point to that end-point
            if valid_minus  && t_minus < i4
               t_minus = i4;
            end
            %Catastrophes tend to happen for quite long, so if there wasn't one before
            %this might be just random fluctuation.
            %To check for this, each time a consecutive shortening of 3 frames happen, 
            %only then we accept it as a catastrophe.
            if t_minus >= 1+num_fitpoints && Data.Track.ToTrack{n}.iscat(1) == 1
                Data.Track.ToTrack{n}.iscat(1) = min(1,Data.Track.ToTrack{n}.iscat(1)+1./3); %1/3 because catastrophes should take at least 3 frames
            elseif t_minus ~= 1 && Data.Track.ToTrack{n}.iscat(1) < 1 && dmin_minus > dseed_threshold
                Data.Track.ToTrack{n}.iscat(1) = min(1,Data.Track.ToTrack{n}.iscat(1)+1./3);
            elseif t_minus ~= 1 && dmin_minus <= dseed_threshold
                if dmin_minus <= dseed_threshold_vclose
                    t_minus = 0;
                else
                    t_minus = 1;
                end
                Data.Track.ToTrack{n}.iscat(1) = 0;
            else
                Data.Track.ToTrack{n}.iscat(1) = 0;
                t_minus = 1;
            end
            
            %Redo same for plus end.
                
            %check if catastrophe happened from plus end to i4
            valid_plus = 1;
            for j4 = i4:size(myvals_diff,2)
               if myvals(2,j4) < avg_bg*thresh_end
                  continue;
               end
               if myvals_diff(1,j4) > abs(thresh_cat_value)/2 || ...
                     sum(myvals_diff(2:end,j4)>abs(thresh_cat_value)/2) > 0 || ...
                     myvals(2,j4) > avg_bg*(1+1.5*(thresh_end-1))
                  valid_plus = 0;
                  break;               
               end
            end
            if valid_plus && t_plus > i4
               t_plus = i4;
            end
            if t_plus <= size(myvals_diff,2)-num_fitpoints && Data.Track.ToTrack{n}.iscat(2)  == 1
                Data.Track.ToTrack{n}.iscat(2) = min(1,Data.Track.ToTrack{n}.iscat(2)+1./3);
            elseif t_plus ~= size(myvals_diff,2) && Data.Track.ToTrack{n}.iscat(2) < 1 && dmin_plus > dseed_threshold
                Data.Track.ToTrack{n}.iscat(2) = min(1,Data.Track.ToTrack{n}.iscat(2)+1./3);
            elseif t_plus ~= size(myvals_diff,2) && dmin_plus <= dseed_threshold
                if dmin_minus <= dseed_threshold_vclose
                    t_plus = size(myvals_diff,2) + 1;
                else
                    t_plus = size(myvals_diff,2);
                end
                Data.Track.ToTrack{n}.iscat(2) = 0;
            else
                Data.Track.ToTrack{n}.iscat(2) = 0;
                t_plus = size(myvals_diff,2);
            end
         end
         
         t_minus = t_minus + lng + add_t_minus;
         t_plus = t_plus + lng + add_t_minus;
      end
   end

   function new_points = variate_points(points, image, maximum, step)
      new_points = size(points);
      for i1 = 1:size(points,1)
         new_points(i1,:) = var_one(i1);
      end
      
      function new_point = var_one(index)
         warning('off','all');
         neigh_fit = polyfit(points(max(1,index-num_fitpoints):min(size(points,1),index+num_fitpoints),1),...
                             points(max(1,index-num_fitpoints):min(size(points,1),index+num_fitpoints),2),...
                             1); %linear fit near point to extrapolate.
         warning('on','all');
         normal = [-neigh_fit(1), 1];
         normal = 1.*normal/norm(normal);
         
         new_vals = size(1,2*maximum + 1);
         for j1 = -maximum:maximum
            s1 = j1*step;
            new_vals(j1+maximum+1) = get_avg_vals(points(index,:)+s1*normal,neigh);
         end
         
         [~,ind_new] = max(new_vals);
         ind_new = ind_new - maximum - 1;
         
         new_point = points(index,:) + ind_new*step*normal;         
      end
   end
end

