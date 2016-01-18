function [ output_args ] = ProcessTracks( Filament, ToTrack, PathName )
%PROCESSTRACK Summary of this function goes here
%   Detailed explanation goes here

global Config Data

  CropSize = Config.analysis.getgfpdata.cropsize / Data.Input.General.PixelSize;
  Enlarge = Data.Input.General.PixelSize / Config.analysis.getgfpdata.croppixelsize;

  savetime = datestr(now,30);
  
%   workbar(0,'Processing track #1','Process Tracks from movie');
  
  for i1 = ToTrack
    
    CropImsMtEnd = getCropIms(Filament(i1), Data.TirfInput.Stack{Data.Input.General.MtStackNum}, CropSize, Enlarge);
    CropImsGfpEnd = getCropIms(Filament(i1), Data.TirfInput.Stack{3-Data.Input.General.MtStackNum}, CropSize, Enlarge);
%     %Third color
%     if numel(Data.TirfInput.Stack) == 3
%     CropImsGfp2End = getCropIms(Filament(i1), Data.TirfInput.Stack{3}, CropSize, Enlarge);
%     end
    
    FilEndFunc = GetFilEndFunc(Filament(i1));
    
    
    Intensities = struct('time',[],...
                         'mt', struct('bg',[], ...
                                      'end',struct('max',[],'mean',[]), ...
                                      'lat',struct('max',[],'mean',[])), ...
                         'gfp', struct('bg',[], ...
                                      'end',struct('max',[],'mean',[]), ...
                                      'lat',struct('max',[],'mean',[])), ...
                         'gfp2',struct('bg',[], ...
                                      'end',struct('max',[],'mean',[]), ...
                                      'lat',struct('max',[],'mean',[])));
                                    
    Intensities.time = Filament(i1).Results(:,2);
    
    [Intensities.mt.bg, ...
     Intensities.mt.end.max,Intensities.mt.end.mean, ...
     Intensities.mt.lat.max, Intensities.mt.lat.mean] ...
        = getIntensities(Filament(i1), CropImsMtEnd);
    
    [Intensities.gfp.bg, ...
     Intensities.gfp.end.max,Intensities.gfp.end.mean, ...
     Intensities.gfp.lat.max, Intensities.gfp.lat.mean] ...
        = getIntensities(Filament(i1), CropImsGfpEnd);
%   %Third color  
%   if numel(Data.TirfInput.Stack) == 3   
%     [Intensities.gfp2.bg, ...
%      Intensities.gfp2.end.max,Intensities.gfp2.end.mean, ...
%      Intensities.gfp2.lat.max, Intensities.gfp2.lat.mean] ...
%         = getIntensities(Filament(i1), CropImsGfp2End);
%   end
  
    f = Filament;
    Filament = Filament(i1); % so we store just the one we used
    
    seedpos = round(Data.Track.ToTrack_marked{i1}.seed);
    moviename = strfind(PathName, '\');
    moviename = PathName(moviename(end-1)+1:end-1);
    savefile = [PathName 'Results\' Config.analysis.getgfpdata.filename, '_' moviename ...
      '_' num2str(seedpos(1)) 'x-' num2str(seedpos(2)) 'y_(' savetime ').mat'];
%   %Third color  
%   if numel(Data.TirfInput.Stack) == 3 
%   save(savefile, ...
%           'CropImsMtEnd', 'CropImsGfpEnd','CropImsGfp2End', 'Intensities', 'FilEndFunc', 'Filament');
%   else
      save(savefile, ...
          'CropImsMtEnd', 'CropImsGfpEnd','Intensities', 'FilEndFunc', 'Filament');
%   end
  
    d.Config = Config;
    d.Data = rmfield(Data,'TirfInput');
    save(savefile,'-struct','d','Data','Config','-append');
    
    Filament = f;
  end
  
  
  
  function CropImStack = getCropIms(Fil, Stack, CropSize, Enlarge)
    CropImStack = cell(numel(Fil.Results(:,1)), 1);
    
%     workbar(0,['Processing track #' num2str(i1) ' ...Cropping images'],'Process Tracks from movie');
    for n = 1 : numel(Fil.Results(:,1));
%       workbar(n/numel(Fil.Results(:,1)),['Processing track #' num2str(i1) ' ...Cropping images'],'Process Tracks from movie');
      CropImStack{n} = subpixcrop(Stack{Fil.Results(n,1)}, Fil.PosEnd(n,:)/Data.Input.General.PixelSize, CropSize, Enlarge);
    end
  end
    
  
end

