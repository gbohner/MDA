function PreSelectedTracks = PreSelectionForAvgGFP( )
%PRESELECTION Summary of this function goes here
%   Detailed explanation goes here

global Config Gui

PreSelectedTracks = {};

mda_disp_mode('flexalign');

[FileName,PathName] = uigetfile([Config.workdir '\*allData_controls.mat'],'Load allData_controls.mat file','MultiSelect','off');
a = load([PathName '\' FileName]);

Time = a.Time;
Position = a.Position;
Intensities = a.Intensities;
Configs = a.Config;
Cods = a.Cods;


  Gui.state.flexalign = 1;
  Gui.state.iterator = 1;
  while Gui.state.flexalign
    if Gui.state.iterator == numel(Time)
      set(Gui.handles.left.next,'String','End');
    end
    
    
    %Set shortname variables
    T = Time{Gui.state.iterator};
    P = Position{Gui.state.iterator};
    P_orig = P;
    Cod = Cods{Gui.state.iterator};

    %Display time-position plot in left window
    mda_disp('left',T, P_orig, T, Cod);

    Gui.state.select = 0;

    uiwait;

    while Gui.state.select 
      
      TrackFilePath = Configs{Gui.state.iterator}.trackFile;
      oldworkdir = strfind(TrackFilePath,'\');
      oldworkdir = TrackFilePath(1:oldworkdir(end-2)-1);
      TrackFilePath = strrep(TrackFilePath, oldworkdir, Config.workdir);
      PreSelectedTracks{end+1}.trackFile = TrackFilePath;
      
      Tint = T(~isnan(P))';
      P = P(~isnan(P));
      Cod = Cod(~isnan(P));
      
      %Get marks from user
        axes(Gui.handles.left.axes);
        left_ylim = get(Gui.handles.left.axes,'YLim');
        left_linehandles = zeros(2,1);
        t = zeros(2,1);        

        %show lines where you've marked
        %point to left
        [t(1),~] = ginput(1);
        left_linehandles(1) = line([t(1), t(1)], [left_ylim(1), left_ylim(2)]);
        
        %point to right
        [t(2),~] = ginput(1);
        left_linehandles(2) = line([t(2), t(2)], [left_ylim(1), left_ylim(2)]);
        
        PreSelectedTracks{end}.time = t;
        
        pause(0.5);
        
        delete(left_linehandles);
        
        mda_disp('left',T, P_orig, T, Cod);
        
        Gui.state.select = 0;
        uiwait;
    end
    
  end      
  
  DirThis = Config.workdir;
  savetime = datestr(now,30);
  save([DirThis '\Tracks_selected_for_AverageGFP_(' savetime ').mat'], 'PreSelectedTracks');
  
  choice = questdlg(['Do you want to run AverageGFP now (with current settings and selection)? ' ...
  'If you want to run it later, tick "Use Pre-selection" then run AverageGFP and choose Tracks_selected file']);

  if strcmp(choice, 'Yes')
    AverageGFP(PreSelectedTracks);
  end

end

