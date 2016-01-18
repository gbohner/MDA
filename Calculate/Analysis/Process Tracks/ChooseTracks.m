function [Tracks, DirRoot] = ChooseTracks()

global Config Gui Data

  Gui.state.choosetracks = 1;
  
  mda_disp_mode('choosetracks');
  set_button_names('on');

  DirRoot = uigetdir(Config.workdir);
  if DirRoot == 0
    warndlg('No folder was chosen, stopping function.');
    return;
  end

  folders = regexp(genpath(DirRoot),';','split');

  Tracks = {};
  
  AllTracks = {};

  for n = 1:numel(folders)-1

     s = what(folders{n});
     if numel(s) == 0
           continue;
     end

     fildata = [];
     for i1 = 1:numel(s.mat)
       try
        if strcmp(s.mat{i1}(1:13),'Filament_Data')
           fildata = [fildata i1];
        end
       end
     end

     s.mat = s.mat(fildata);

     for m = 1:numel(s.mat)
        a = load([s.path '\' s.mat{m}]);
        for i1 = 1:numel(a.Filament)
           %skip too short tracks (less then 10 frames)
           if size(a.Filament(i1).Results,1) < 10
             continue;
           end
           fe = GetFilEndFunc(a.Filament(i1));
           
           AllTracks{end+1}.file = [s.path '\' s.mat{m}];
           AllTracks{end}.filendfunc = fe;
           AllTracks{end}.num = i1;
        end
     end
  end

  if isempty(AllTracks)
    return;
  end
  
  Gui.state.iterator = 1;
  while Gui.state.choosetracks
    choosetracks_disp();
    
    if Gui.state.iterator == numel(AllTracks)
      Gui.state.choosetracks = 0;
    end
    
    Gui.state.select = 0;
    cur = Gui.state.iterator;
    uiwait;
    
    if Gui.state.select == 1
      Gui.state.iterator = cur + 1;
      Gui.state.select = 0;
      continue;
    elseif Gui.state.iterator > cur
      if isempty(Tracks)
        Tracks{1}.file = AllTracks{cur}.file;
        Tracks{1}.num = AllTracks{cur}.num;
      else
        if strcmp(Tracks{end}.file, AllTracks{cur}.file)
          Tracks{end}.num = [Tracks{end}.num, AllTracks{cur}.num];
        else
          Tracks{end+1}.file = AllTracks{cur}.file;
          Tracks{end}.num = AllTracks{cur}.num;
        end
      end
    end
  end
    
 
  DirThis = [fileparts( mfilename('fullpath') ) filesep];
  save([DirThis '\Tracks_to_do.mat'], 'Tracks');

  set_button_names('off');
  mda_disp_mode('basic');
  Gui.state.choosetracks = 0;

  function choosetracks_disp()
    argcell{1} = 'left';
    argcell{2} = AllTracks{Gui.state.iterator}.filendfunc(:,1);
    argcell{3} = AllTracks{Gui.state.iterator}.filendfunc(:,2);
    
    mda_disp(argcell{:});
  end
  
  function set_button_names(str)
    switch str
      case 'on'
        set(Gui.handles.left.select,'String','Skip');
        set(Gui.handles.left.next,'String','Accept');
      case 'off'
        set(Gui.handles.left.select,'String','Select');
        set(Gui.handles.left.next,'String','Next');
    end
  end

end