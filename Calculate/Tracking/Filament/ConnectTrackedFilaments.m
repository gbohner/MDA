function ConnectTrackedFilaments()
%CONNECTTRACKEDFILAMENTS Summary of this function goes here
%   Detailed explanation goes here

global Data;

num = validFils();

for n = num
   seed = Data.Track.ToTrack{n}.seed;
   ori = Data.Track.ToTrack{n}.ori;
   frames = Data.Track.ToTrack{n}.frames;
%    if frames(1) == Data.Track.current.frames
      [obj_num, p, ind] = find_fil(seed, ori);
%    else
%       prev = Data.Track.FilTrack{n}(end,:);
%       obj_num = find_fil(seed, ori, prev);
%    end
      
   

   if p>0.6
      Data.Track.FilTrack{n}(end+1,:) = [Data.Track.current.frame, obj_num];
      objs = Data.Track.Objects{Data.Track.current.frame};
      x = objs.data{obj_num}{1}(:, 1)./Data.Input.General.PixelSize; 
      y = objs.data{obj_num}{1}(:, 2)./Data.Input.General.PixelSize;
      Data.Track.ToTrack{n}.points = [x, y];
      rad = Data.Track.Objects{Data.Track.current.frame}.orientation(obj_num);
      Data.Track.ToTrack{n}.ori = double([cos(rad) sin(rad)]);
      data = Data.Track.Objects{Data.Track.current.frame}.data{obj_num}{1};
      Data.Track.ToTrack{n}.seed = [data(ind,1) data(ind,2)]./Data.Input.General.PixelSize;
   elseif p>0.4
      Data.Track.FilTrack{n}(end+1,:) = [Data.Track.current.frame, obj_num];
   else
      %No Object found
      continue
   end   
end




   function [obj_num, p, ind]= find_fil(seed, ori)
      objs = Data.Track.Objects{Data.Track.current.frame};
      if ~isfield(objs, 'data') || sum(size(objs)) == 0
         obj_num = 1; p = 0; ind = 1;
         return;
      end
      inds = [];
      probs = zeros(1,numel(objs.data));
      for m = 1:numel(objs.data)
         x = objs.data{m}{1}(:, 1)./Data.Input.General.PixelSize; 
         y = objs.data{m}{1}(:, 2)./Data.Input.General.PixelSize;
         [dmin, ind] = min(sqrt((x-seed(1)).^2 + (y-seed(2)).^2));
         inds(end+1) = ind;
         ori2 = -objs.orientation(m);
         ddeg1 = min(abs([ori2-asin(ori(2)), ori2 - asin(ori(2)) + pi, ...
            ori2 - acos(ori(1)), ori2 - acos(ori(1)) + pi]));
         ori2 = objs.orientation(m);
         ddeg2 = min(abs([ori2-asin(ori(2)), ori2 - asin(ori(2)) + pi, ...
            ori2 - acos(ori(1)), ori2 - acos(ori(1)) + pi]));
         ddeg = min([ddeg1 ddeg2]);
         probs(m) = 0.5 * 1/nthroot(dmin+1, 4) + 0.5 * (pi-ddeg)^2/pi^2;
         if dmin > 20 %It's surely an other microtubule
             probs(m) = 0;
         end
      end
      [p obj_num] = max(probs);
      ind = inds(obj_num);
   end

   function n = validFils()
      n=[];
      for k = 1:numel(Data.Track.ToTrack)
         frames = Data.Track.ToTrack{k}.frames;
         frame = Data.Track.current.frame;
         if frames(1)<=frame && frame<=frames(2)
            n = [n k];
         end
      end
   end


end

