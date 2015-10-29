function AvgSlopes = AlignedSlopes( AvgTime, MarkedPos)
%ALIGNEDSLOPES Summary of this function goes here
%   Detailed explanation goes here

CurSlopes = nan(size(AvgTime, 1), size(MarkedPos, 2));
ws = 2; %window size: 2,  means from x-2 to x+2, 5 data points, -> 2 sec using 2 fps

for i1 = 1:numel(MarkedPos)
  for j = 1:size(AvgTime)
      try
          f = @(x,data)x(1).*data+x(2);
          tofitpos = double(MarkedPos{1,i1}(max(j-ws,1):min(j+ws,end)));
          tofittime = double(AvgTime(max(j-ws,1):min(j+ws,end)));
          if sum(~isnan(tofitpos)) < length(tofitpos)
            continue
          end
          x_cur = lsqcurvefit(f, [mean(diff(tofitpos)), tofitpos(1)-tofittime(1)*mean(diff(tofitpos))], ...
            tofittime, tofitpos,...
            [],[],optimset('Display','off'));
      catch
          continue
      end
      CurSlopes(j, i1) = x_cur(1);
  end
  plot(AvgTime, CurSlopes(:,i1))
  drawnow;
  pause(0.1);
end

AvgSlopes = nanmean(CurSlopes, 2);

plot(AvgTime, AvgSlopes)

end

