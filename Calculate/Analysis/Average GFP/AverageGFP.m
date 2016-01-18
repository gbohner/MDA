function AvgedImages = AverageGFP(varargin)
%AVERAGEGFP Creates averaged images from manually marked periods and fits

global Config Gui Data;

    %TODO - add option to average only stuff n times higher than bg intensity;
 
    
    mda_disp_mode('averagegfp');
    toggle_buttons('on')
    
    Gui.handles.display.averagegfp = @averagegfp_disp;

    DirRoot = Config.workdir;
    imname = Config.analysis.averagegfp.imname;
    models{1} = Config.analysis.averagegfp.models.mt;
    models{2} = Config.analysis.averagegfp.models.gfp;
    
    choose_align = Config.analysis.averagegfp.choose_align;
    
    saveavgims = Config.analysis.averagegfp.saveavgims;
    savefitims = Config.analysis.averagegfp.savefitims;
    savevideos = Config.analysis.averagegfp.savevideos;
    
    %Maximum cropsizes: 6.4 um.
    %If you're aligning as well, use < 5 um
    MT_cropsize = Config.analysis.averagegfp.MT_cropsize;
    GFP_cropsize = Config.analysis.averagegfp.GFP_cropsize;
    NewAlignThresh = Config.analysis.averagegfp.NewAlignThresh;
    
    MT_cropsize = MT_cropsize/2;
    GFP_cropsize = GFP_cropsize/2;

    %create folder for imname if not existing
    folderseparators = strfind(imname, '\');
    lastsep = folderseparators(end);
    if ~isempty(lastsep)
      if ~isdir([DirRoot '\' imname(1:lastsep-1)])
         mkdir([DirRoot '\' imname(1:lastsep-1)]);
      end
    end
    imname = [DirRoot '\' imname];
    
    %Load alignment images if alignment was chosen
    if choose_align
      AlignParams = struct('bead_im',struct('gfp',[],'mt',[]),...
                     'filpos',[],...
                     'Twarp',[],...
                     'rho',1,...
                     'settings',struct('levels', 1, 'noi', 100, 'transform', 'homography')...
                     );
     AlignParams.bead_im.gfp = Config.analysis.averagegfp.bead_im.gfp;
     AlignParams.bead_im.mt = Config.analysis.averagegfp.bead_im.mt;
    else
      AlignParams = [];
    end

    
%Creates a list of folders containing all subfolders of the marked one
folders = regexp(genpath(DirRoot),';','split');

AvgedImages = {};

%check if tracks were preselected
if nargin > 0
    PreSelected = [varargin{1}{:}];
    AllTracks = {PreSelected(:).trackFile};
    AllTimes = {PreSelected(:).time};
else

    %store all track file paths to enable user to go to previous track etc
    AllTracks = {};
    AllTimes = {};

    for n = 1:numel(folders)-1
       %Run through all subfolders and load all trackedFilamentData... files.

       s = what(folders{n});
       if numel(s) == 0
             continue;
       end

       fildata = [];
       for i1 = 1:numel(s.mat)
          if length(s.mat{i1}) >= 19
             if strcmp(s.mat{i1}(1:19),'trackedFilamentData')
                fildata = [fildata i1];
             end
          end
       end

       s.mat = s.mat(fildata);

       for m = 1:numel(s.mat)
          AllTracks{end+1} = [s.path '\' s.mat{m}];
       end
    end
end

%Now all file paths are stored in the AllTracks cell array.

if isempty(AllTracks)
  warndlg('No tracks were found');
  return;
end


%Save config because it changes during fitting process
generalConfig = Config;

Gui.state.erase = 0;
Gui.state.averagegfp = 1;
Gui.state.iterator = 1;
while Gui.state.averagegfp   
    if Gui.state.iterator >= numel(AllTracks)
      set(Gui.handles.left.next,'String','End');
      if Gui.state.iterator > numel(AllTracks)
        Gui.state.iterator = numel(AllTracks);
      end
    end
  
     %Load the trackedFilamentData... files from the saved path
      a = load(AllTracks{Gui.state.iterator});
      
%       a.CropImsGfpEnd = a.CropImsMtEnd;
%       a.Intensities.gfp = a.Intensities.mt;
      
      AvgIm = struct('mt', struct('im',[],'im_nobg',[],'fit',[], 'cod',[],'model',models{1},'linescan',[]),...
                     'gfp',struct('im',[],'im_nobg',[],'fit',[], 'cod',[],'model',models{2},'linescan',[]),...
                     'gfp2',struct('im',[],'im_nobg',[],'fit',[], 'cod',[],'model',models{2},'linescan',[]),...
                     'posdiff',[],...
                     'orientation',[],...
                     'FPS',[],...
                     'pixelsize',[],...
                     'frames',[],...
                     'length',[],...
                     'file',[],...
                     'Config',[],...
                     'Align_rho',[]);
           
      if isfield(a.Filament,'Cods')
        mda_disp('left',a.FilEndFunc(:,1),a.FilEndFunc(:,2),a.FilEndFunc(:,1), a.Filament.Cods(:,2));
      else
        mda_disp('left',a.FilEndFunc(:,1),a.FilEndFunc(:,2));
      end
      
      %Plots the FilEndFunction, user can choose averaging episodes
      
      if ~isempty(AllTimes)
        Gui.state.select = 1;
      else
        Gui.state.select = 0;
      end
      
      uiwaitif(isempty(AllTimes));
      
      while Gui.state.select        

          if savevideos
            set(Gui.handles.right.popup,'Value',1);
          end
        
          toggle_buttons('off');
          
          if ~isempty(AllTimes)
              %set timeframe automatically
              t = AllTimes{Gui.state.iterator};
              
              axes(Gui.handles.left.axes);
              left_ylim = get(Gui.handles.left.axes,'YLim');
              left_linehandles = zeros(2,1);
              left_linehandles(1) = line([t(1), t(1)], [left_ylim(1), left_ylim(2)]);
              left_linehandles(2) = line([t(2), t(2)], [left_ylim(1), left_ylim(2)]);
              
          else
              %set timeframe by hand
          
              axes(Gui.handles.left.axes);
              left_ylim = get(Gui.handles.left.axes,'YLim');
              left_linehandles = zeros(2,1);
              t = zeros(2,1);
              [t(1),~] = ginput(1);

              %show lines where you've marked
              left_linehandles(1) = line([t(1), t(1)], [left_ylim(1), left_ylim(2)]);

              [t(2),~] = ginput(1);
              left_linehandles(2) = line([t(2), t(2)], [left_ylim(1), left_ylim(2)]);
              
              pause(0.5);
              
          end

          %Get the growthspeed by 1D fit to the time-pos data in the timeframe
          AvgIm.growthSpeed = GetGrowthSpeed(a.FilEndFunc, t);

          T = t;

          FPS = a.Data.Input.General.FPS;
          %Modify t, so that it's now same frames as the time marked
          t = roundto(t+1/FPS,1/FPS) - a.FilEndFunc(1,1); %round up to 1/FPS, then subtract first frame
          t = t * FPS;


          %Get other properties of the current averaging episode
          AvgIm.frames = [ceil(t(1)),floor(t(2))] + a.FilEndFunc(1,1)*FPS;
          AvgIm.length = floor(T(2)) - ceil(T(1)) + 1/FPS;
          AvgIm.FPS = FPS;
          AvgIm.pixelsize = a.Config.analysis.getgfpdata.croppixelsize;

          ind(1) = FindFilFrameIndex(a.Filament(1), AvgIm.frames(1));
          ind(2) = FindFilFrameIndex(a.Filament(1), AvgIm.frames(2));

          AvgIm.orientation = mod(angle(sum(exp(1i*a.Filament(1).Results(ind(1):ind(2),8)))),2*pi);
          AvgIm.file = AllTracks{Gui.state.iterator};
          AvgIm.Config = a.Config;


          
          %Create the averaged images by simply putting them on top of eachother
          %If user wanted alignment, calculate it when needed and apply to GFP image              
          align_ind = FindFilFrameIndex(a.Filament(1), AvgIm.frames(1));                           
          croppedimsize = size(a.CropImsGfpEnd{min(ceil(t(1))+1,end)});

          if choose_align
            AlignParams = SetLocalAlign(a.Filament, 1, align_ind, Config.analysis.getgfpdata.cropsize, a.Data.Input.General.PixelSize, AvgIm.pixelsize, AlignParams);
            AlignParams.filpos = a.FilEndFunc(ceil(t(1)),2);
          end

          %% Create averaged GFP image
          AvgIm.gfp.im = zeros(size(a.CropImsGfpEnd{min(ceil(t(1))+1,end)}));
          Video_gfp = [];
          image_stack_gfp = {};
          num = 0;
          for j = ceil(t(1)):floor(t(2))
            if choose_align ...
                && (abs(AlignParams.filpos - a.FilEndFunc(min(j+1,end),2)) > NewAlignThresh ...
                    || AlignParams.rho < 0.8)
              align_ind = FindFilFrameIndex(a.Filament(1), AvgIm.frames(1)+j-ceil(t(1))+1);
              AlignParams = SetLocalAlign(a.Filament, 1, align_ind, Config.analysis.getgfpdata.cropsize, a.Data.Input.General.PixelSize, AvgIm.pixelsize, AlignParams);
              AlignParams.filpos = a.FilEndFunc(min(j+1,end),2);
            end 


            im = double(a.CropImsGfpEnd{min(j+1,end)});
            if choose_align
              im = LocalAlign(im, AlignParams);
              AvgIm.Align_rho(end+1,1) = AlignParams.rho;
            end
            
            filindex = FindFilFrameIndex(a.Filament(1),j);
            if a.Intensities.gfp.end.max(filindex) > Config.analysis.averagegfp.skipdarkgfp * a.Intensities.gfp.bg(filindex)
              AvgIm.gfp.im = AvgIm.gfp.im + im;
              num = num+1;
            end

            averagegfp_disp('Average GFP');
            
            if savevideos
              frame = getframe(Gui.handles.right.axes);
              Video_gfp(:,:,:,end+1) = uint8(frame.cdata);
              image_stack_gfp{end+1} = im;
              if j == ceil(t(1))
                Video_gfp = uint8(Video_gfp);
              end
            end
          end
          
          if num == 0
            delete(left_linehandles);
            warndlg(['All the images were skipped due to too high setting'...
              'of the minimum of ( max_end_intensity - bg )/ bg. Try a lower value. ']);
            uiwaitif(isempty(AllTimes));
            toggle_buttons('on');
            uiwaitif(isempty(AllTimes));
            continue;
          end

          AvgIm.gfp.im = double(AvgIm.gfp.im) ./ num;

         

          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


          %% Create averaged MT image
          AvgIm.mt.im = zeros(size(a.CropImsMtEnd{min(ceil(t(1))+1,end)}));
          Video_mt = [];
          image_stack_mt = {};
          for j = ceil(t(1)):floor(t(2))
              im = double(a.CropImsMtEnd{min(j+1,end)});
              
              filindex = FindFilFrameIndex(a.Filament(1),j);
              if a.Intensities.gfp.end.max(filindex) > Config.analysis.averagegfp.skipdarkgfp * a.Intensities.gfp.bg(filindex)
                AvgIm.mt.im = AvgIm.mt.im + im;
              end

              averagegfp_disp('Average MT');
              
              if savevideos
                frame = getframe(Gui.handles.right.axes);
                Video_mt(:,:,:,end+1) = uint8(frame.cdata);
                image_stack_mt{end+1} = im;
                if j == ceil(t(1))
                  Video_mt = uint8(Video_mt);
                end
              end
          end          


          AvgIm.mt.im = double(AvgIm.mt.im) ./ num;

          
           %% Create averaged GFP2 image (3rd colour)
%  %Third color
%  if numel(Data.TirfInput.Stack) == 3           
%           AvgIm.gfp2.im = zeros(size(a.CropImsGfp2End{min(ceil(t(1))+1,end)}));
%           image_stack_gfp2 = {};
%           for j = ceil(t(1)):floor(t(2))
%               
%                if choose_align ...
%                 && (abs(AlignParams.filpos - a.FilEndFunc(min(j+1,end),2)) > NewAlignThresh ...
%                     || AlignParams.rho < 0.8)
%               align_ind = FindFilFrameIndex(a.Filament(1), AvgIm.frames(1)+j-ceil(t(1))+1);
%               AlignParams = SetLocalAlign(a.Filament, 1, align_ind, Config.analysis.getgfpdata.cropsize, a.Data.Input.General.PixelSize, AvgIm.pixelsize, AlignParams);
%               AlignParams.filpos = a.FilEndFunc(min(j+1,end),2);
%             end 
%               
%               im = double(a.CropImsGfp2End{min(j+1,end)});
%               if choose_align
%               im = LocalAlign(im, AlignParams);
%               AvgIm.Align_rho(end+1,1) = AlignParams.rho;
%             end
%               
%               filindex = FindFilFrameIndex(a.Filament(1),j);
%               if a.Intensities.gfp.end.max(filindex) > Config.analysis.averagegfp.skipdarkgfp * a.Intensities.gfp.bg(filindex)
%                 AvgIm.gfp2.im = AvgIm.gfp2.im + im;
%               end
% 
%               averagegfp_disp('Average Chn 3');
%             
%           end          
% 
% 
%           AvgIm.gfp2.im = double(AvgIm.gfp2.im) ./ num;
%           
%  end         
          
%% Calculate the classic intensity values for the average image
          AvgIm.Intensities = struct(...
                         'mt', struct('bg',[], ...
                                      'end',struct('max',[],'mean',[]), ...
                                      'lat',struct('max',[],'mean',[])), ...
                         'gfp',struct('bg',[], ...
                                      'end',struct('max',[],'mean',[]), ...
                                      'lat',struct('max',[],'mean',[])));

          orivec = [cos(AvgIm.orientation) sin(AvgIm.orientation)];
          
          [AvgIm.Intensities.mt.bg, ...
           AvgIm.Intensities.mt.end.max,AvgIm.Intensities.mt.end.mean, ...
           AvgIm.Intensities.mt.lat.max, AvgIm.Intensities.mt.lat.mean] ...
              = getIntensities(struct('PosStart',[0 0], 'PosEnd', orivec), {AvgIm.mt.im});

          [AvgIm.Intensities.gfp.bg, ...
           AvgIm.Intensities.gfp.end.max,AvgIm.Intensities.gfp.end.mean, ...
           AvgIm.Intensities.gfp.lat.max, AvgIm.Intensities.gfp.lat.mean] ...
              = getIntensities(struct('PosStart',[0 0], 'PosEnd', orivec), {AvgIm.gfp.im});
          AvgIm.Intensities.gfp.norm = (AvgIm.Intensities.gfp.end.mean - AvgIm.Intensities.gfp.lat.mean) ./ ...
            (AvgIm.Intensities.mt.lat.mean + Config.analysis.flexalign.params.laplacesmoothing);
          

%% FITTING %%%%%%%%%%%%%%%%%%%%%

          %Subtract uneven background
          AvgIm.mt.im_nobg = AvgIm.mt.im - imopen(AvgIm.mt.im,strel('disk',25));
          AvgIm.gfp.im_nobg = AvgIm.gfp.im - imopen(AvgIm.gfp.im,strel('disk',25));
%           %Third color
%           if numel(Data.TirfInput.Stack) == 3  
%           AvgIm.gfp2.im_nobg = AvgIm.gfp2.im - imopen(AvgIm.gfp2.im,strel('disk',25));    
%           end

          [AvgIm.mt.fit,  AvgIm.mt.cod ] = DoFitting('mt');
          [AvgIm.gfp.fit, AvgIm.gfp.cod] = DoFitting('gfp');

          %Calculate distance between gfp and mt's end position along the mt
          AvgIm.posdiff = AvgIm.mt.fit.x(:).value - AvgIm.gfp.fit.x(:).value;

          ori = [-cos(AvgIm.mt.fit.o.value) -sin(AvgIm.mt.fit.o.value)];

          AvgIm.posdiff = AvgIm.posdiff' * ori';
          AvgIm.posdiff = AvgIm.posdiff * a.Config.analysis.getgfpdata.croppixelsize;

%               if strcmp(models{1},'e')
%                  %Add half of FWHM to posdiff, so it's counted from half maximum of gauss func
%                  AvgIm.posdiff = AvgIm.posdiff - AvgIm.mt.fit.w(1).value * 2*sqrt(2*log(2)) * a.Config.analysis.getgfpdata.croppixelsize;
%               end

          %Convert values to easily understandable ones
          AvgIm = create_fit_result(AvgIm);

          % Calculating and plotting 1D stuff
          AvgIm = create_linescans(AvgIm);          

          AvgedImages{end+1} = AvgIm;
              
          if saveavgims
            %Write average GFP image to file
            imwrite(uint16(AvgIm.gfp.im_nobg),[imname '_' num2str(numel(AvgedImages)) '_avg_gfp.tif'],'tif');
%             %Third color
%             if numel(Data.TirfInput.Stack) == 3 
%             imwrite(uint16(AvgIm.gfp2.im_nobg),[imname '_' num2str(numel(AvgedImages)) '_avg_gfp2.tif'],'tif')
%             end
            %Write average MT image
            imwrite(uint16(AvgIm.mt.im_nobg),[imname '_' num2str(numel(AvgedImages)) '_avg_mt.tif'],'tif');              
          end
          
          if savefitims
            [mtfitim, gfpfitim] = PlotAvgFit(AvgIm, 1);
            %Write fitted GFP image to file
            imwrite(uint16(gfpfitim),[imname '_' num2str(numel(AvgedImages)) '_fit_gfp.tif'],'tif')
            %Write fitted MT image
            imwrite(uint16(mtfitim),[imname '_' num2str(numel(AvgedImages)) '_fit_mt.tif'],'tif');
          end

          %Write both channel videos to files if needed
          if savevideos
            %write image stack
            saveastiffopt.color = false;
            saveastiffopt.comp = 'no';
            saveastiffopt.append = true;
            for i174 = 1:numel(image_stack_gfp)
              saveastiff2(uint16(image_stack_gfp{i174}), [imname '_' num2str(numel(AvgedImages)) '_stack_gfp.tif'], saveastiffopt);
            end
            for i174 = 1:numel(image_stack_mt)
              saveastiff2(uint16(image_stack_mt{i174}), [imname '_' num2str(numel(AvgedImages)) '_stack_mt.tif'], saveastiffopt);
            end
            %write video
            choose_to_savethisvideo = questdlg('Save these averaging videos?','Save videos','Yes','No','Yes');
            if strcmp(choose_to_savethisvideo,'Yes')
              [FileName, PathName] = uiputfile('*.avi','Set video filename',DirRoot);
              framerate = inputdlg('Video frame rate');
              framerate = str2num(framerate{1});
              vw = VideoWriter([PathName FileName(1:end-4) '_gfp' FileName(end-3:end)]);
              vw.FrameRate = framerate;
              open(vw);
              writeVideo(vw,uint8(Video_gfp));
              close(vw);
              vw = VideoWriter([PathName FileName(1:end-4) '_mt' FileName(end-3:end)]);
              vw.FrameRate = framerate;
              open(vw);
              writeVideo(vw,uint8(Video_mt));
              close(vw);
            end
          end
          
          %display current selection
          val = get(Gui.handles.right.popup,'Value');
          disptype = get(Gui.handles.right.popup,'String');
          disptype = disptype{val};
          if ~strcmp(disptype,'Auto')
            averagegfp_disp(disptype);
          end
          
          Gui.state.select = 0;
          
          toggle_buttons('on');
          delete(left_linehandles);
          
          if isfield(a.Filament,'Cods')
            mda_disp('left',a.FilEndFunc(:,1),a.FilEndFunc(:,2),a.FilEndFunc(:,1), a.Filament.Cods(:,2));
          else
            mda_disp('left',a.FilEndFunc(:,1),a.FilEndFunc(:,2));
          end
          
          uiwaitif(isempty(AllTimes));
          if Gui.state.erase == 1
            AvgedImages = AvgedImages(1:end-1);
            warndlg('You have successfully erased current entry');
            Gui.state.erase = 0;
            set(Gui.handles.right.popup,'Enable','off');
            set(Gui.handles.right.erase,'Enable','off');
            uiwaitif(isempty(AllTimes));
            set(Gui.handles.right.popup,'Enable','on');
            set(Gui.handles.right.erase,'Enable','on');
          end
          
          if ~isempty(AllTimes)
              Gui.state.iterator = Gui.state.iterator + 1;
              if Gui.state.iterator > numel(AllTracks)
                  Gui.state.averagegfp = 0;
              end
          end
      end
end

%set Config back
Config = generalConfig;
save([imname '_AveragedData.mat'], 'AvgedImages');
exporttoexcel(AvgedImages,[imname '_AveragedData.xls']);

mda_disp_mode('basic');


  function [v,l] = DoFitting(str)
      if strcmp(str,'mt')
         fit_model = models{1};
         useim = AvgIm.mt.im_nobg;
         fitori = AvgIm.orientation;

         mid = (size(useim)+1)/2;
         maximum = max(max(double(useim(mid(1)-20:mid(1)+20,mid(2)-20:mid(2)+20))));
         newsize = min([MT_cropsize / a.Config.analysis.getgfpdata.croppixelsize, mid-1,size(useim)-mid-1]); %40
         useim = useim(mid(1)-newsize:mid(1)+newsize, mid(2)-newsize:mid(2)+newsize); % don't fit whole image, cause seed
         toadd = abs(mid - newsize)-1;
      else
         fit_model = models{2};
         fitori = AvgIm.orientation;
         
         useim = AvgIm.gfp.im_nobg;

         mid = (size(useim,1)+1)/2;
         maximum = max(max(double(useim(mid-20:mid+20,mid-20:mid+20))));
         newsize = min(GFP_cropsize / a.Config.analysis.getgfpdata.croppixelsize, mid-1); %40
         useim = useim(mid-newsize:mid+newsize, mid-newsize:mid+newsize); % don't fit whole image, cause seed
         toadd = abs(mid - newsize)-1;

         maximum = max(max(double(useim)));
      end

      global pic bw;

      pic = double(useim);
      bw = im2bw(pic/max(max(pic)),0.7);

      pixelsize = a.Data.Input.General.PixelSize;
      griddensity = a.Data.Input.General.PixelSize/a.Config.analysis.getgfpdata.croppixelsize;


      if strcmp(fit_model,'u')
        if strcmp(str,'mt')
          l_guess = [3000, 3000];
        else
          l_guess = [10, 100];
        end
        [v,l,c] = Fit2D(fit_model, struct('obj', 1, 'model', fit_model, 'x', (size(pic)+1)/2, 'o', fitori,...
                    'mtLattice',3*mean2(pic)/max(max(pic)),'h',maximum,'w',200/pixelsize*griddensity,'l',l_guess),  ...
                struct('background', mean2(pic(pic<0.2*max(max(pic)))),'fit_size',(size(pic,1)-1)/2 ,'display',1, ...
                'options', struct('MaxIter', 1400, 'MaxFunEvals', 3600, 'TolX', 1e-6, 'TolFun', 1e-6, 'JacobMult', [])));
      else
        [v,l,c] = Fit2D(fit_model, struct('obj', 1, 'model', fit_model, 'x', (size(pic)+1)/2, 'o', fitori,...
                    'mtLattice',3*mean2(pic)/max(max(pic)),'h',maximum,'w',200/pixelsize*griddensity), ...
                struct('background', mean2(pic),'fit_size',(size(pic,1)-1)/2 ,'display',1, ...
                'options', struct('MaxIter', 200, 'MaxFunEvals', 1000, 'TolX', 1e-6, 'TolFun', 1e-6, 'JacobMult', [])));
      end


      v.x = v.x + toadd;

  end

  function averagegfp_disp(type)
     argcell = {};
     argcell{1} = 'right';
     argcell{2} = type;
     switch type
       case 'Average MT'
%          argcell{3} = AvgIm.mt.im;
         argcell{3} = AvgIm.mt.im(round(croppedimsize/8): croppedimsize - round(croppedimsize/8),...
           round(croppedimsize/8): croppedimsize - round(croppedimsize/8)); 
       case 'Average GFP'
%          argcell{3} = AvgIm.gfp.im;
         argcell{3} = AvgIm.gfp.im(round(croppedimsize/8): croppedimsize - round(croppedimsize/8),...
           round(croppedimsize/8): croppedimsize - round(croppedimsize/8)); 
       case 'Average Chn 3'
%          argcell{3} = AvgIm.gfp2.im;
%           %Third color
%           if numel(Data.TirfInput.Stack) == 3 
%          argcell{3} = AvgIm.gfp2.im(round(croppedimsize/8): croppedimsize - round(croppedimsize/8),...
%            round(croppedimsize/8): croppedimsize - round(croppedimsize/8)); 
%           end
       case 'MT axial linescan'
         argcell(3:5) = {AvgIm.mt.linescan.orig.axial.d, AvgIm.mt.linescan.orig.axial.i, 'b'};
         argcell(6:8) = {AvgIm.mt.linescan.fit.axial.d, AvgIm.mt.linescan.fit.axial.i, 'r'};
       case 'MT lateral linescan' 
         argcell(3:5) = {AvgIm.mt.linescan.orig.lateral.d, AvgIm.mt.linescan.orig.lateral.i, 'b'};
         argcell(6:8) = {AvgIm.mt.linescan.fit.lateral.d, AvgIm.mt.linescan.fit.lateral.i, 'r'};
       case 'GFP axial linescan'
         argcell(3:5) = {AvgIm.gfp.linescan.orig.axial.d, AvgIm.gfp.linescan.orig.axial.i, 'b'};
         argcell(6:8) = {AvgIm.gfp.linescan.fit.axial.d, AvgIm.gfp.linescan.fit.axial.i, 'r'};
       case 'GFP lateral linescan'
         argcell(3:5) = {AvgIm.gfp.linescan.orig.lateral.d, AvgIm.gfp.linescan.orig.lateral.i, 'b'};
         argcell(6:8) = {AvgIm.gfp.linescan.fit.lateral.d, AvgIm.gfp.linescan.fit.lateral.i, 'r'};
       case 'MT-GFP axial linescan'
         argcell(3:5) = {AvgIm.mt.linescan.orig.axial.d, AvgIm.mt.linescan.orig.axial.i, 'b'};
         argcell(6:8) = {AvgIm.mt.linescan.fit.axial.d, AvgIm.mt.linescan.fit.axial.i, '-.c'};
         argcell(9:11) = {AvgIm.gfp.linescan.orig.axial.d, AvgIm.gfp.linescan.orig.axial.i, 'r'};
         argcell(12:14) = {AvgIm.gfp.linescan.fit.axial.d, AvgIm.gfp.linescan.fit.axial.i, '-.m'};
       case 'MT-GFP lateral linescan'
         argcell(3:5) = {AvgIm.mt.linescan.orig.lateral.d, AvgIm.mt.linescan.orig.lateral.i, 'b'};
         argcell(6:8) = {AvgIm.mt.linescan.fit.lateral.d, AvgIm.mt.linescan.fit.lateral.i, '-.c'};
         argcell(9:11) = {AvgIm.gfp.linescan.orig.lateral.d, AvgIm.gfp.linescan.orig.lateral.i, 'r'};
         argcell(12:14) = {AvgIm.gfp.linescan.fit.lateral.d, AvgIm.gfp.linescan.fit.lateral.i, '-.m'};
       otherwise
         return;
     end
     
     if Config.analysis.advanced.shownormalised
       if numel(argcell) > 3
         for i13 = 4 : 6 : numel(argcell)
           divby = max(argcell{i13});
           argcell{i13} = argcell{i13} / divby;
           argcell{i13 + 3} = argcell{i13 + 3} / divby;
         end
       end
     end

     mda_disp(argcell{:});
  end

  function toggle_buttons(str)
    buttons = [Gui.handles.left.prev, Gui.handles.left.select, Gui.handles.left.next,...
               Gui.handles.right.popup];
    for i2 = buttons
      set(i2,'Enable',str);
    end
  end

  function uiwaitif(statement)
      if statement
          uiwait;
      end
  end

  function AvgIm = create_fit_result(AvgIm)
    wpx = AvgIm.pixelsize; %pixel size of fitted images
          
    %Create structs, then fill them up
    AvgIm.mt.fit_result = struct('x0',[],'ori',NaN,'psf',NaN,'w',NaN,'h',NaN,...
      'tau',NaN, 'bg', NaN);
    AvgIm.gfp.fit_result = struct('x0',[],'ori',NaN,'psf',NaN,'w',NaN,'h',NaN,...
      'tau',NaN, 'bg', NaN);

    AvgIm.mt.fit_result.x0 = AvgIm.mt.fit.x(1:2).value; % in pixels
    AvgIm.mt.fit_result.ori = AvgIm.mt.fit.o.value/pi*180; %in degrees
    AvgIm.mt.fit_result.psf = AvgIm.mt.fit.w(1).value * wpx; %in nm
    try
      AvgIm.mt.fit_result.w = AvgIm.mt.fit.w(2).value * wpx; %in nm
    end
    AvgIm.mt.fit_result.h = AvgIm.mt.fit.h.value; % in AU   
    if strcmp(models{1},'u')
      AvgIm.mt.fit_result.tau = AvgIm.mt.fit.l(1).value * wpx; % in nm
      AvgIm.mt.fit_result.h = AvgIm.mt.fit_result.h * wpx; %in AU, multiply by pixelsize, because h/tau must stay same
    end

    AvgIm.gfp.fit_result.x0 = AvgIm.gfp.fit.x(1:2).value; % in pixels
    AvgIm.gfp.fit_result.ori = AvgIm.gfp.fit.o.value/pi*180; %in degrees
    AvgIm.gfp.fit_result.psf = AvgIm.gfp.fit.w(1).value * wpx; %in nm
    try
      AvgIm.gfp.fit_result.w = AvgIm.gfp.fit.w(2).value * wpx; %in nm
    end
    AvgIm.gfp.fit_result.h = AvgIm.gfp.fit.h.value; % in AU   
    if strcmp(models{2},'u')
      AvgIm.gfp.fit_result.tau = AvgIm.gfp.fit.l(1).value * wpx; % in nm
      AvgIm.gfp.fit_result.h = AvgIm.gfp.fit_result.h * wpx; %in AU, multiply by pixelsize, because h/tau must stay same
    elseif strcmp(models{2}, 'v')
      AvgIm.gfp.fit_result.tau = AvgIm.gfp.fit.l(1).value * wpx; % in nm
      AvgIm.gfp.fit_result.lat = AvgIm.gfp.fit.l(2).value; %in AU
      AvgIm.gfp.fit_result.h = AvgIm.gfp.fit_result.h * wpx; %in AU, multiply by pixelsize, because h/tau must stay same
    elseif strcmp(models{2},'c')
      AvgIm.gfp.fit_result.tau = (1/AvgIm.gfp.fit.l(1).value) * wpx;
    elseif strcmp(models{2},'a')
      AvgIm.gfp.fit_result.lat = AvgIm.gfp.fit.l(1).value;
    end
  end

  function AvgIm = create_linescans(AvgIm)
    %Get fit images
    [mtfitim, gfpfitim] = PlotAvgFit(AvgIm, 1);

    %Get 1D plots of mt and gfp, axial and lateral, original and fit for each
    mt_orig_1d_along = GetLineScan(AvgIm.mt.im_nobg, AvgIm.mt.fit.x(:).value', AvgIm.mt.fit.o.value', AvgIm.pixelsize);
    mt_fit_1d_along = GetLineScan(mtfitim, AvgIm.mt.fit.x(:).value', AvgIm.mt.fit.o.value', AvgIm.pixelsize);
    mt_orig_1d_cross = GetLineScan(AvgIm.mt.im_nobg, AvgIm.mt.fit.x(:).value', AvgIm.mt.fit.o.value' + pi/2, AvgIm.pixelsize);
    mt_fit_1d_cross = GetLineScan(mtfitim, AvgIm.mt.fit.x(:).value', AvgIm.mt.fit.o.value' + pi/2, AvgIm.pixelsize);

    gfp_orig_1d_along = GetLineScan(AvgIm.gfp.im_nobg, AvgIm.mt.fit.x(:).value', AvgIm.mt.fit.o.value', AvgIm.pixelsize);
    gfp_fit_1d_along = GetLineScan(gfpfitim, AvgIm.mt.fit.x(:).value', AvgIm.mt.fit.o.value', AvgIm.pixelsize);
    gfp_orig_1d_cross = GetLineScan(AvgIm.gfp.im_nobg, AvgIm.mt.fit.x(:).value', AvgIm.mt.fit.o.value' +pi/2, AvgIm.pixelsize);
    gfp_fit_1d_cross = GetLineScan(gfpfitim, AvgIm.mt.fit.x(:).value', AvgIm.mt.fit.o.value'+pi/2, AvgIm.pixelsize);

    AvgIm.mt.linescan.orig.axial.d = mt_orig_1d_along(:,1);
    AvgIm.mt.linescan.orig.axial.i = mt_orig_1d_along(:,2);
    AvgIm.mt.linescan.fit.axial.d = mt_fit_1d_along(:,1);
    AvgIm.mt.linescan.fit.axial.i = mt_fit_1d_along(:,2);
    AvgIm.mt.linescan.orig.lateral.d = mt_orig_1d_cross(:,1);
    AvgIm.mt.linescan.orig.lateral.i = mt_orig_1d_cross(:,2);
    AvgIm.mt.linescan.fit.lateral.d = mt_fit_1d_cross(:,1);
    AvgIm.mt.linescan.fit.lateral.i = mt_fit_1d_cross(:,2);

    AvgIm.gfp.linescan.orig.axial.d = gfp_orig_1d_along(:,1);
    AvgIm.gfp.linescan.orig.axial.i = gfp_orig_1d_along(:,2);
    AvgIm.gfp.linescan.fit.axial.d = gfp_fit_1d_along(:,1);
    AvgIm.gfp.linescan.fit.axial.i = gfp_fit_1d_along(:,2);
    AvgIm.gfp.linescan.orig.lateral.d = gfp_orig_1d_cross(:,1);
    AvgIm.gfp.linescan.orig.lateral.i = gfp_orig_1d_cross(:,2);
    AvgIm.gfp.linescan.fit.lateral.d = gfp_fit_1d_cross(:,1);
    AvgIm.gfp.linescan.fit.lateral.i = gfp_fit_1d_cross(:,2);
  end

    
end

