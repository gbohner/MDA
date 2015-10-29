  function [bg, endmax, endmean, latmax, latmean] = getIntensities(Fil, CropImStack)
  
    global Config
  
    bg = zeros(numel(CropImStack),1);
    endmax = zeros(numel(CropImStack),1);
    endmean = zeros(numel(CropImStack),1);
    latmax = zeros(numel(CropImStack),1);
    latmean = zeros(numel(CropImStack),1);
    
    boxsize = Config.analysis.getgfpdata.getintensities.boxsize / Config.analysis.getgfpdata.croppixelsize;
    boxbehind = Config.analysis.getgfpdata.getintensities.boxbehind / Config.analysis.getgfpdata.croppixelsize;
    
%     workbar(0,['Processing track #' num2str(i1) ' ...Getting intensities'],'Process Tracks from movie');
    for n = 1 : numel(CropImStack)
%       workbar(n/numel(CropImStack),['Processing track #' num2str(i1) ' ...Getting intensities'],'Process Tracks from movie');
      deg = Fil.PosEnd(n,:) - Fil.PosStart(n,:);
      deg = atan2(deg(2),deg(1));
      
      im = CropImStack{n};
      
      bg(n) = GetBgInt(im);
      
      im = imrotate(im, double(deg/pi*180));
      
      im = im - bg(n);
      
      mid = size(im)/2;
      endbox = im(round(mid(2)-boxsize(2)/2) : round(mid(2)+boxsize(2)/2),...
                  round(mid(1)-boxsize(1)/3*2) : round(mid(1)+boxsize(1)/3));
      latbox = im(round(mid(2)-boxsize(2)/2) : round(mid(2)+boxsize(2)/2),...
                  round(mid(1)- boxsize(1)/3*5 - boxbehind) : round(mid(1)- boxsize(1)/3*2 - boxbehind));
                
      endmax(n) = max(endbox(:));
      endmean(n) = mean(endbox(:));
      latmax(n) = max(latbox(:));
      latmean(n) = mean(latbox(:));           
    end
    
  end
