function [ output_args ] = popup_batch_gui(varargin )
%POPUP_BATCH_GUI Summary of this function goes here
%   Detailed explanation goes here
global Config Data Gui;
%    Gui.general.panelbackground = [0.94 0.94 0.62];
%     Gui.general.panelbackground = [0.7608, 0.8392, 0.8549];

warning('off','all');

if ~isfield(Data.Track, 'Batch')
  Data.Track.Batch = {};
end

tracked_folders = {};
for i1 = 1:length(Data.Track.Batch)
  tracked_folders{i1} = Data.Track.Batch{i1}.General.PathName;
end

    
%  Initialization tasks
scrsz = get(0,'ScreenSize');
scale = Gui.general.scale; %Recommended {1, 4/3, 24/15, 24/18, 7/3}
h_batchfigure = figure('MenuBar','none','Toolbar','none','Visible','on','Name','Batch',...
   'Position',[scrsz(3)/2-round(300*scale) scrsz(4)-round(330*scale)-50 round(360*scale), round(150*scale)],'Color',Gui.general.panelbackground,...
   'CloseRequestFcn', @close_popup_gui);

h_batchpopup = uicontrol('Parent', h_batchfigure,'Style','popupmenu','String',tracked_folders,...
   'Units', 'pixels', 'Position', [20 100 200 20]*scale);
h_delete_single = uicontrol('Parent', h_batchfigure,'Style','pushbutton','String','Delete from batch',...
   'Units', 'pixels', 'Position', [260 100 80 20]*scale,'Callback',@delete_current_callback,...
   'Visible','on','HorizontalAlignment','left');
 
h_clearbatch = uicontrol('Parent', h_batchfigure,'Style','pushbutton','String','Clear batch',...
   'Units', 'pixels', 'Position', [20 20 80 40]*scale,'Callback',@clear_batch_callback,...
   'Visible','on','HorizontalAlignment','left');
 
h_savebatch = uicontrol('Parent', h_batchfigure,'Style','pushbutton','String','Save batch',...
   'Units', 'pixels', 'Position', [140 20 80 40]*scale,'Callback',@save_batch_callback,...
   'Visible','on','HorizontalAlignment','left');
 
h_loadbatch = uicontrol('Parent', h_batchfigure,'Style','pushbutton','String','Load batch',...
   'Units', 'pixels', 'Position', [260 20 80 40]*scale,'Callback',@load_batch_callback,...
   'Visible','on','HorizontalAlignment','left');
 
 
 function delete_current_callback(varargin)
    num = get(h_batchpopup,'Value');
    Data.Track.Batch(num) = [];
    tracked_folders(num) = [];
    set(h_batchpopup, 'Value',1);
    set(h_batchpopup, 'String',tracked_folders);
    set(Gui.handles.track.add_to_batch, 'String', ['Add to Batch (' num2str(length(Data.Track.Batch)) ')']);
 end

  function clear_batch_callback(varargin)
    Data.Track.Batch = {};
    tracked_folders = {};
    set(h_batchpopup, 'String',tracked_folders);
    set(Gui.handles.track.add_to_batch, 'String', ['Add to Batch (' num2str(length(Data.Track.Batch)) ')']);
  end

  function save_batch_callback(varargin)
    [FileName,PathName,FilterIndex] = uiputfile([Config.workdir '\*.mat'],'Save batch file');
    if PathName == 0
      warndlg('No file was chosen, stopping function.');
      return;
    end
    Batch = Data.Track.Batch;
    save(strcat(PathName, FileName), 'Batch');
  end

  function load_batch_callback(varargin)
    [FileName,PathName,FilterIndex] = uigetfile([Config.workdir '\*.mat'],'Save batch file','MultiSelect','off');
    if PathName == 0
      warndlg('No file was chosen, stopping function.');
      return;
    end
    a = load(strcat(PathName, FileName));
    Data.Track.Batch = a.Batch;
    tracked_folders = {};
    for i2 = 1:length(Data.Track.Batch)
      tracked_folders{i2} = Data.Track.Batch{i2}.General.PathName;
    end
    set(h_batchpopup, 'String',tracked_folders);
    set(Gui.handles.track.add_to_batch, 'String', ['Add to Batch (' num2str(length(Data.Track.Batch)) ')']);
  end

  function close_popup_gui(varargin)
    warning('on','all');
    closereq;
  end
end

