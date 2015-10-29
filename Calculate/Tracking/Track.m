function [ output_args ] = Track()
%ANALYSE Summary of this function goes here
%   Detailed explanation goes here

%Include global variables.
global Config Data Gui
global pic bw

  Gui.state.tracking = 1;

  %Setup data objects for storing results for marked MTs.
  Data.Track.Objects = {};
  Data.Track.FilTrack = cell(1,numel(Data.Track.ToTrack));

  %Determine which frames to track MTs on
  cStack_num = Data.Input.General.MtStackNum;
  Data.Track.frames = [1e6 0];
  for i1 = 1:numel(Data.Track.ToTrack)
     if Data.Track.frames(1)>Data.Track.ToTrack{i1}.frames(1)
        Data.Track.frames(1) = Data.Track.ToTrack{i1}.frames(1);
     end
     if Data.Track.frames(2)<Data.Track.ToTrack{i1}.frames(2)
        Data.Track.frames(2) = Data.Track.ToTrack{i1}.frames(2);
     end
  end

  Data.Track.current.frame = Data.Track.frames(1);

  %Looks ahead a couple frames to avoid mistracking due to single-frame fluctuations
  Data.Track.current.thr = cell(1,2+Config.settings.lookahead);
  for i1=-1:Config.settings.lookahead
     t = Threshold(Data.TirfInput.Stack{cStack_num}{max(Data.Track.current.frame+i1,2)});
     t.DoThreshold(Config.settings.threshold.ThreshParams);
     Data.Track.current.thr{i1+2} = t;
  end

  myh = [];
%Main tracking cycle, goes through all "interesting" (marked MT present) frames.
while Data.Track.current.frame <= Data.Track.frames(2)
  %Workbar to show current progress of tracking.
   workbar((Data.Track.current.frame - Data.Track.frames(1)) / (Data.Track.frames(2)-Data.Track.frames(1)),...
      ['Analyzing frame ' num2str(Data.Track.current.frame) '...']);
   if isempty(validFils()) %see if any MTs to track on current frame
      Data.Track.current.frame = Data.Track.current.frame + 1;
      continue
   end


   t = Data.Track.current.thr{2}; %Find current thresholded image
   Data.Track.current.image = t.input; %Make it the currently used image
   if mod(Data.Track.current.frame,100) == 0
     disp('1');
   end
   bw = t.DynamicMarked(); %Create a binary picture containing only points of marked MTs
   Data.Track.current.image_bw = bw;
   %Finding and parameterizing objects on the binary image for later fitting
   [objects, params] = RoughScan(t.input, t.output, bw);
   
   %shift threshold images
   %  {1}  - previous frame
   %  {2}  - current frame
   %  {3+} - next frames (# stored in Config.settings.lookahead)
   for i11 = 1:numel(Data.Track.current.thr)-1
      Data.Track.current.thr{i11} = Data.Track.current.thr{i11+1};
   end
   %Calculate the new filtered frame
   Data.Track.current.thr{end} = Threshold(Data.TirfInput.Stack{cStack_num}{min(Data.Track.current.frame+1+Config.settings.lookahead,Data.Track.frames(2))});
   Data.Track.current.thr{end}.DoThreshold(Config.settings.threshold.ThreshParams);
   
   %Disregard small objects found
   del = [];
   for n = 1:numel(objects)
      if numel(objects(n).p) < 2
         del = [del n];
      end
      %Add a third point for small 2-point MTs
      if numel(objects(n).p) == 2
         objects(n).p(end+1) = objects(n).p(end);
         objects(n).p(end).x = objects(n).p(end-1).x +[0.1 0.1];
      end
   end
   objects(del) = [];
      
   
   %Draw objects found via RoughScan
   if ishandle(myh)
      set(myh,'Visible','off')
   end
   lslider_CB(Data.Track.current.frame);
   rslider_CB(Data.Track.current.frame);
   drawnow;
   myh = [];
   for i74 = 1:numel(objects)
    obp = objects(i74).p;
    ob = zeros(numel(obp),2);
    for j74 = 1:numel(obp)
      ob(j74,:) = obp(j74).x';
    end    
    set(Gui.handles.left.axes, 'NextPlot', 'add');
    set(Gui.handles.right.axes, 'NextPlot', 'add');
    myh = [myh scatter(Gui.handles.left.axes, ob(:,1),ob(:,2),3 )];
    if ~isempty(Gui.data.right.rect)
      %TODO change this silly rectangle thing as well
      rect = Gui.data.right.rect;
    else
      rect = [0 0];
    end
    myh = [myh scatter(Gui.handles.right.axes, ob(:,1)-rect(1)+1,ob(:,2)-rect(2)+1,3 )];
    set(Gui.handles.left.axes, 'NextPlot', 'replacechildren');
    set(Gui.handles.right.axes, 'NextPlot', 'replacechildren');
   end
   drawnow;
   
   pic = double(Data.TirfInput.Stack{cStack_num}{Data.Track.current.frame});
   objects = FineScan( objects, params );
   
   objects = InterpolateData( objects, t.output, params );

   objects = orderfields(objects);
   
   Data.Track.Objects{Data.Track.current.frame} = objects;
   
   ConnectTrackedFilaments(); %set Data.Track.FilTrack and modify Data.Track.ToTrack
   
   %Step to the next frame
   Data.Track.current.frame = Data.Track.current.frame + 1;
end

   if ishandle(myh)
      set(myh,'Visible','off')
   end

   %Save the object results to pathname\Results folder with video filename and timestamp
   results_dir = [Data.Input.General.PathName '\Results'];
   if ~isdir(results_dir)
      mkdir(results_dir);
   end
   fn = char(Data.Input.General.FileName(1));
   fn = fn(1:end-8);
   t = datestr(now,30);
   Objects = Data.Track.Objects;
   FilTrack = Data.Track.FilTrack;
   save([results_dir '\' fn '_(' t ')_rawdata.mat'], 'Objects', 'FilTrack');
   
   %Create the Filament struct, containing tracked data for all tracked filaments
   %in an organized manner, then also saving it.
   Filament = afterfeatureconnect_as_func();

   Gui.state.tracking = 0;
end

function n = validFils()
   global Data;
   n=[];
   for k = 1:numel(Data.Track.ToTrack)
      frames = Data.Track.ToTrack{k}.frames;
      frame = Data.Track.current.frame;
      if frames(1)<=frame && frame<=frames(2)
         n = [n k];
      end
   end
end