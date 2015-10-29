function GrowthSpeed = GetGrowthSpeed( FilEndFunc, t )
%GETGROWTHSPEED Fits a 1D slope to the time-position (sec/nm) plot in the given t timeframe
%   Returns the growth speed value in um/min

f = @(x,data)x(1).*data+x(2);

FilEndFunc = double(FilEndFunc);

FilEndFunc = FilEndFunc(~isnan(FilEndFunc(:,2)),:);

findstart = find(abs(FilEndFunc(:,1)-ceil(t(1)))==min(abs((FilEndFunc(:,1)-ceil(t(1))))),1,'first');
findend = find(abs(FilEndFunc(:,1)-floor(t(2)))==min(abs((FilEndFunc(:,1)-floor(t(2))))),1,'first');

timefit = FilEndFunc(max(findstart,1) : min(findend,end), 1);
posfit = FilEndFunc(max(findstart,1) : min(findend,end), 2);

result = lsqcurvefit(f, [mean(diff(posfit)) posfit(1)], timefit, posfit);

GrowthSpeed = result(1);

% figure; plot(timefit,posfit);

%Convert from nm/sec to um/min
GrowthSpeed = GrowthSpeed/1000*60;

end

