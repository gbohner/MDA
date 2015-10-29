% load allData_controls.mat manually

%calculate slope at all possible points.
Slope = {};

for i1 = 1:numel(Position)
  if i1 > 1
    fprintf(repmat('\b',1,numel(msg)+1));
  end
  msg = ['Calculating slope ' num2str(i1) '/' num2str(numel(Position))];
  disp(msg);
  pos = smooth(Position{i1},15,'rloess');
  x = NaN(length(pos), 2);
  for j = find(~isnan(pos),1,'first')+3:find(~isnan(pos),1,'last')-3
      try
          f = @(x,data)x(1).*data+x(2);
          tofit = double(pos(max(j-3,1):min(j+3,end)));
          x(j, :) = lsqcurvefit(f, [mean(diff(tofit)) tofit(1)], 0:length(tofit)-1, tofit',...
            [],[],optimset('Display','off'));
      catch
          x(j,:) = [NaN NaN];
          continue
      end
  end
  Slope{i1} = x(:,1);
end

%find growth periods
min_growth = -10; %nm/frame
min_length = 100; % in frames
GrowthPeriods = {};
for i1 = 1:numel(Slope)
  smooth_slope = smooth(Slope{i1},15,'moving');%Slope{i1};
  good_slope = (smooth_slope>min_growth);
  good_slope = diff([0; good_slope; 0]);
  periods = find(good_slope==1)';
  periods(2,:) = find(good_slope==-1)';
  periods(3,:) = diff(periods);
  
  for i2 = 1:size(periods,2)
    if periods(3,i2) > min_length
      GrowthPeriods{end+1}.num = i1;
      GrowthPeriods{end}.Config = Config{i1};
      GrowthPeriods{end}.Time = Time{i1}(periods(1,i2):periods(2,i2));
      GrowthPeriods{end}.Position = Position{i1}(periods(1,i2):periods(2,i2));
      GrowthPeriods{end}.Slope = Slope{i1}(periods(1,i2):periods(2,i2));
      GrowthPeriods{end}.Cods = Cods{i1}(periods(1,i2):periods(2,i2));
      GrowthPeriods{end}.Intensities.gfp.end.max = Intensities{i1}.gfp.end.max(periods(1,i2):periods(2,i2));
      GrowthPeriods{end}.Intensities.gfp.end.mean = Intensities{i1}.gfp.end.mean(periods(1,i2):periods(2,i2));
    end
  end
end

%calculate the autocorrelation (subtract mean and normalise first)
AllACF = [];
for i1 = 1:numel(GrowthPeriods)
  intensity = GrowthPeriods{i1}.Intensities.gfp.end.mean;
  intensity = intensity - mean(intensity);
  [ACF,lags,bounds] = autocorr(intensity,min(199,numel(intensity)-1));
  ACF = padarray(ACF, 200-numel(ACF), NaN, 'post');
  AllACF = [AllACF ACF];
end

AvgACF = nanmean(AllACF,2);

fit_length = 100;
fps = 2;

plot((0:fit_length-1)/fps, AvgACF(1:fit_length),'b');
xlabel('Time (sec)');
ylabel('Autocorr');

fit_ExpDec = @(p,x_data)p(1)*exp(-x_data/p(2))+p(3);
fit_ExpDec_only_t1 = @(p,x_data)exp(-x_data/p(1))+p(2);
data.x = (0:fit_length-1)'/fps;
data.y = AvgACF(1:fit_length);
x0 = [1, 5, 0];
  
[x1, resnorm, residuals] = lsqcurvefit(fit_ExpDec, x0, data.x, data.y);
[x2, resnorm, residuals,~,~,~,jacobian] = lsqcurvefit(fit_ExpDec_only_t1, x0(2:3), data.x, data.y);

CoD = 1 - sum( residuals(:).^2 ) / sum( ( data.y - mean( data.y ) ).^2 );
  
hold on;
% plot(data.x, fit_ExpDec(x1,data.x),'r');
% title(['Decay Time: ' num2str(x1(2)) ' sec']);
plot(data.x, fit_ExpDec_only_t1(x2,data.x),'r');
title(['Decay Time: ' num2str(x2(1)) ' sec']);
  
  