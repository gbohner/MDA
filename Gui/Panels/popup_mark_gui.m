function [ output_args ] = popup_mark_gui(varargin )
%POPUP_BATCH_GUI Summary of this function goes here
%   Detailed explanation goes here
global Config Data Gui;
%    Gui.general.panelbackground = [0.94 0.94 0.62];
%     Gui.general.panelbackground = [0.7608, 0.8392, 0.8549];

warning('off','all');

if ~isfield(Data.Track, 'ToTrack')
  Data.Track.ToTrack = {};
end

if ~isfield(Data, 'TirfInput')
  warndlg('There is no movie loaded, aborting...');
  return;
end

mt_seed_handles = [];
mt_seed_current = [];

mean_im = [Data.TirfInput.Stack{Data.Input.General.MtStackNum}{:}];
mean_im = reshape(mean_im,size(Data.TirfInput.Stack{Data.Input.General.MtStackNum}{1},1), size(Data.TirfInput.Stack{Data.Input.General.MtStackNum}{1},2), []);
mean_im = mean(mean_im,3);
mean_im = mean_im - min(mean_im(:));
mean_im = mean_im./max(mean_im(:));
 
tracked_folders = {};
for i1 = 1:length(Data.Track.ToTrack)
  tracked_folders{i1} = num2str(round(Data.Track.ToTrack{i1}.seed));
end

    
%  Initialization tasks
scrsz = get(0,'ScreenSize');
scale = Gui.general.scale; %Recommended {1, 4/3, 24/15, 24/18, 7/3}
h_batchfigure = figure('MenuBar','figure','Toolbar','none','Visible','on','Name','Marks',...
   'Position',[scrsz(3)/2-round(300*scale) scrsz(4)-round(600*scale)-50 round(360*scale), round(500*scale)],'Color',Gui.general.panelbackground,...
   'CloseRequestFcn', @close_popup_gui);

h_batchpopup = uicontrol('Parent', h_batchfigure,'Style','popupmenu','String',tracked_folders,...
   'Units', 'pixels', 'Position', [20 100 200 20]*scale,'Callback',@batch_popup_callback);
h_delete_single = uicontrol('Parent', h_batchfigure,'Style','pushbutton','String','Delete from marked',...
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
 
 h_im_axes = axes('Parent', h_batchfigure, 'Units', 'pixels', 'Position', [20 150 320 320]*scale);
 imshow(mean_im);
 plot_mt_seeds()
 hold on;
 if ~isempty(Data.Track.ToTrack)
  mt_seed_current =  scatter(Data.Track.ToTrack{1}.seed(1), Data.Track.ToTrack{1}.seed(2), 145, 'go');
 end


 function batch_popup_callback(varargin)
    axes(h_im_axes)
    num = get(h_batchpopup,'Value');
    delete(mt_seed_current);    
    hold on;
    mt_seed_current =  scatter(Data.Track.ToTrack{num}.seed(1), Data.Track.ToTrack{num}.seed(2), 145, 'go');
  end

 function delete_current_callback(varargin)
   axes(h_im_axes)
    num = get(h_batchpopup,'Value');
    Data.Track.ToTrack(num) = [];
    tracked_folders(num) = [];
    set(h_batchpopup, 'Value',1);
    set(h_batchpopup, 'String',tracked_folders);
    plot_mt_seeds()
 end

  function clear_batch_callback(varargin)
    axes(h_im_axes)
    Data.Track.ToTrack = {};
    tracked_folders = {};
    set(h_batchpopup, 'String',tracked_folders);
    plot_mt_seeds()
  end

  function save_batch_callback(varargin)
    [FileName,PathName,FilterIndex] = uiputfile([Config.workdir '\*.mat'],'Save batch file');
    if PathName == 0
      warndlg('No file was chosen, stopping function.');
      return;
    end
    ToTrack = Data.Track.ToTrack;
    save(strcat(PathName, FileName), 'ToTrack');
  end

  function load_batch_callback(varargin)
    axes(h_im_axes)
    [FileName,PathName,FilterIndex] = uigetfile([Config.workdir '\*.mat'],'Save batch file','MultiSelect','off');
    if PathName == 0
      warndlg('No file was chosen, stopping function.');
      return;
    end
    a = load(strcat(PathName, FileName));
    Data.Track.ToTrack = a.ToTrack;
    tracked_folders = {};
    for i2 = 1:length(Data.Track.ToTrack)
      tracked_folders{i2} = num2str(round(Data.Track.ToTrack{i2}.seed));
    end
    set(h_batchpopup, 'String',tracked_folders);
    plot_mt_seeds()
  end

  function plot_mt_seeds()
    axes(h_im_axes)
     delete(mt_seed_handles);
     mt_seed_handles = [];
     for i2 = 1:length(Data.Track.ToTrack)
       hold on;
       mt_seed_handles(i2) = text(Data.Track.ToTrack{i2}.seed(1), Data.Track.ToTrack{i2}.seed(2), num2str(i2), 'Color', 'r');
     end
  end

  function close_popup_gui(varargin)
    warning('on','all');
    closereq;
  end


end

