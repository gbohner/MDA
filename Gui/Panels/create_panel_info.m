function [ output_args ] = create_panel_info( parent, pos, scale )
%PANEL_TRACK Summary of this function goes here
%   Detailed explanation goes here

global Config Data Gui

h_infopanel = uipanel('Parent', parent, 'Units', 'pixels', 'Position', pos, 'Visible', 'on',...
   'Title','Information');
 
h_workdirlabel = uicontrol('Parent', h_infopanel,'Style','text','String','Work dir.: ',...
   'Units', 'pixels', 'Position', [20 113 55 30]*scale,'FontSize',9,...
   'Visible','on');
 
h_workdir = uicontrol('Parent', h_infopanel,'Style','pushbutton','String',Config.workdir,...
   'TooltipString',Config.workdir,'Units', 'pixels', 'Position', [80 120 110 30]*scale,'Callback',@workdir_callback,...
   'Visible','on','HorizontalAlignment','right');
 
h_fpslabel = uicontrol('Parent', h_infopanel,'Style','text','String','Frames per second: ',...
   'Units', 'pixels', 'Position', [20 78 115 30]*scale,'FontSize',9,...
   'Visible','on');
 
h_fps = uicontrol('Parent', h_infopanel,'Style','edit','String',num2str(Data.Input.General.FPS),...
   'Units', 'pixels', 'Position', [140 85 50 30]*scale,'Callback',@fps_callback,...
   'FontSize',11,'Visible','on');
 
h_pixelsizelabel = uicontrol('Parent', h_infopanel,'Style','text','String','Pixel size (nm): ',...
   'Units', 'pixels', 'Position', [20 38 87 30]*scale,'FontSize',9,...
   'Visible','on');
 
h_pixelsize = uicontrol('Parent', h_infopanel,'Style','edit','String',num2str(Data.Input.General.PixelSize),...
   'Units', 'pixels', 'Position', [140 45 50 30]*scale,'Callback',@pixelsize_callback,...
   'FontSize',11,'Visible','on');
 
h_mtchannellabel = uicontrol('Parent', h_infopanel,'Style','text','String','Tracked channel: ',...
   'Units', 'pixels', 'Position', [20 3 87 30]*scale,'FontSize',9,...
   'Visible','on');

h_mtchannel = uicontrol('Parent', h_infopanel,'Style','edit','String',num2str(Data.Input.General.MtStackNum),...
   'Units', 'pixels', 'Position', [140 10 50 30]*scale,'Callback',@mtchannel_callback,...
   'FontSize',11,'Visible','on');

 
 Gui.handles.info.mtchannel = h_mtchannel;
 Gui.handles.info.callbacks.mtchannel = @mtchannel_callback;
 
 function workdir_callback(hObj, event)
    newdir = uigetdir(Config.workdir);
    if newdir == 0
      warndlg('No folder was chosen, stopping function.');
      return;
    end
    Config.workdir = newdir;
    set(hObj,'String',Config.workdir);
    set(hObj,'TooltipString',Config.workdir);
    
    DirThis = [fileparts( mfilename('fullpath') ) filesep];
    perarray = strfind(DirThis, '\');
    basicsettingsfile = [DirThis(1:perarray(end-2)-1) '\Settings\basic_settings.mat'];
    
    save(basicsettingsfile, '-struct', 'Config', 'workdir');
    temp = Data.Input.General;
    save(basicsettingsfile, '-struct', 'temp', 'FPS', 'PixelSize', 'MtStackNum', '-append');
 end

 function fps_callback(hObj, event)
    Data.Input.General.FPS = ...
      str2double(get(hObj,'String'));
  
    DirThis = [fileparts( mfilename('fullpath') ) filesep];
    perarray = strfind(DirThis, '\');
    basicsettingsfile = [DirThis(1:perarray(end-2)-1) '\Settings\basic_settings.mat'];
    
    save(basicsettingsfile, '-struct', 'Config', 'workdir');
    temp = Data.Input.General;
    save(basicsettingsfile, '-struct', 'temp', 'FPS', 'PixelSize', 'MtStackNum', '-append');
 end

  function pixelsize_callback(hObj, event)
    Data.Input.General.PixelSize = ...
      str2double(get(hObj,'String'));
  
    DirThis = [fileparts( mfilename('fullpath') ) filesep];
    perarray = strfind(DirThis, '\');
    basicsettingsfile = [DirThis(1:perarray(end-2)-1) '\Settings\basic_settings.mat'];
    
    save(basicsettingsfile, '-struct', 'Config', 'workdir');
    temp = Data.Input.General;
    save(basicsettingsfile, '-struct', 'temp', 'FPS', 'PixelSize', 'MtStackNum', '-append');
  end

  function mtchannel_callback(hObj, varargin)
    Data.Input.General.MtStackNum = str2double(get(hObj,'String'));
    
    DirThis = [fileparts( mfilename('fullpath') ) filesep];
    perarray = strfind(DirThis, '\');
    basicsettingsfile = [DirThis(1:perarray(end-2)-1) '\Settings\basic_settings.mat'];
    
    save(basicsettingsfile, '-struct', 'Config', 'workdir');
    temp = Data.Input.General;
    save(basicsettingsfile, '-struct', 'temp', 'FPS', 'PixelSize', 'MtStackNum', '-append');
  end
 
end

