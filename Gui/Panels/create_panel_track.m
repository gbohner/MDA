function [ output_args ] = create_panel_track( parent, pos, scale )
%PANEL_TRACK Summary of this function goes here
%   Detailed explanation goes here

  global Config Data Gui;

  h_trpanel = uipanel('Parent', parent, 'Units', 'pixels', 'Position', pos, 'Visible', 'on',...
   'Title','Track');

  %Button for loading new movies
  h_loadmovies = uicontrol('Parent', h_trpanel,'Style','pushbutton','String','Load movies',...
   'Units', 'pixels', 'Position', [20 110 120 50]*scale,'Callback',@loadmovies_callback,...
   'Visible','on');

%   %Button for changing advanced settings
%   h_advsettings = uicontrol('Parent', h_trpanel,'Style','pushbutton','String','Advanced Settings',...
%    'Units', 'pixels', 'Position', [20 30 120 30]*scale,'Callback',@advsettings_callback,...
%    'Visible','on');

  %Button for batch tracking
  h_batchtrack = uicontrol('Parent', h_trpanel,'Style','pushbutton','String','Add to Batch (0)',...
   'Units', 'pixels', 'Position', [20 70 120 30]*scale,'Callback',@batchtrack_callback,...
   'Visible','on');
 
  h_batchoperation = uicontrol('Parent', h_trpanel,'Style','pushbutton','String','Batch Operations',...
   'Units', 'pixels', 'Position', [20 30 120 30]*scale,'Callback',@popup_batch_gui,...
   'Visible','on');

  %Button for marking a new microtubule
  h_mark = uicontrol('Parent', h_trpanel,'Style','pushbutton','String','Mark',...
   'Units', 'pixels', 'Position', [160 110 120 50]*scale,'Callback',@mark_callback,...
   'Visible','on');
 
  %Button for erasing last mark
  h_eraselast = uicontrol('Parent', h_trpanel,'Style','pushbutton','String','Erase last mark',...
   'Units', 'pixels', 'Position', [160 70 120 30]*scale,'Callback',@eraselast_callback,...
   'Visible','on');
 
 %Button for erasing all marked mts in this session
%   h_eraseall = uicontrol('Parent', h_trpanel,'Style','pushbutton','String','Erase all marked',...
%    'Units', 'pixels', 'Position', [160 30 120 30]*scale,'Callback',@eraseall_callback,...
%    'Visible','on');

  h_markoperation  = uicontrol('Parent', h_trpanel,'Style','pushbutton','String','Mark Operations',...
   'Units', 'pixels', 'Position', [160 30 120 30]*scale,'Callback',@popup_mark_gui,...
   'Visible','on');
 
 %Label for threshold setting
  h_threshlabel = uicontrol('Parent', h_trpanel,'Style','text','String','Threshold: ',...
   'Units', 'pixels', 'Position', [320 108 60 30]*scale,'FontSize',9,...
   'Visible','on');

  h_threshedit = uicontrol('Parent', h_trpanel,'Style','edit',...
    'String',num2str(Config.settings.threshold.ThreshParams.Threshold),...
   'Units', 'pixels', 'Position', [390 120 30 20]*scale,'Callback',@threshedit_callback,...
   'Visible','on');
 
 h_filteredit = uicontrol('Parent', h_trpanel,'Style','edit',...
   'String',num2str(Config.settings.threshold.ThreshParams.Wallis.args{2}),...
   'Units', 'pixels', 'Position', [430 120 50 20]*scale,'Callback',@filteredit_callback,...
   'Visible','on');
 
 h_trackmodellabel = uicontrol('Parent', h_trpanel,'Style','text','String','End fit: ',...
   'Units', 'pixels', 'Position', [320 75 40 30]*scale,'FontSize',9,...
   'Visible','on');
 
  h_trackmodelpopup = uicontrol('Parent', h_trpanel,'Style','popupmenu',...
    'String',ModelLibrary( 'MT_end' ),...
   'Units', 'pixels', 'Position', [370 80 110 30]*scale,'Callback',@trackmodelpopup_callback);
 
 %Button for tracking
  h_track = uicontrol('Parent', h_trpanel,'Style','pushbutton','String','Track',...
   'Units', 'pixels', 'Position', [320 30 160 50]*scale,'Callback',@track_callback,...
   'Visible','on');
 
 
 Gui.handles.track.add_to_batch = h_batchtrack;
 Gui.handles.track.callbacks.batchtrack = @batchtrack_callback;
 
  function loadmovies_callback(varargin)
    TrackingMainFunc('Load');
  end

  function advsettings_callback(varargin)
    config_gui();
  end

  function batchtrack_callback(varargin)
    if ~isfield(Data.Track, 'Batch')
      Data.Track.Batch = {};
    end
    Data.Track.Batch{end+1}.ToTrack = Data.Track.ToTrack;
    Data.Track.Batch{end}.General = Data.Input.General;
    set(h_batchtrack, 'String', ['Add to Batch (' num2str(length(Data.Track.Batch)) ')']);
    Data.Track.ToTrack = {};
  end

  function mark_callback(varargin)
    try
      num = numel(Data.Track.ToTrack);
      TrackingMainFunc('Mark');
    catch
      str = 'off';
      Gui.state.marking = 0;
      set(Gui.handles.right.slider2,'Visible',str);
      set(Gui.handles.right.slider2_edit,'Visible',str);
      set(Gui.handles.right.slider2_apply,'Visible',str);
      if numel(Data.Track.ToTrack) > num
        Data.Track.ToTrack = Data.Track.ToTrack(1:end-1);
        warndlg('Current marking failed. Data removed automatically. Try again!')
      end
    end
  end

  function eraselast_callback(varargin)
    num = numel(Data.Track.ToTrack);
    if num > 0
      Data.Track.ToTrack = Data.Track.ToTrack(1:end-1);
      warndlg({'You have successfully removed the last track', ...
        [num2str(num-1) ' tracks remaining']});
      if numel(Data.Track.ToTrack) == 0
        Gui.state.marking = 0;
      end
    else
      warndlg('No tracks were removed');
    end
  end

  function eraseall_callback(varargin)
    answer = questdlg('Are you sure you want to erase all?', 'Yes','No','No');
    if strcmp(answer,'Yes')
      Data.Track.ToTrack = [];
      warndlg('You have successfully removed all tracks');
      Gui.state.marking = 0;
    end
  end

  function threshedit_callback(hObj, event)
    Config.settings.threshold.ThreshParams.Threshold = ...
      str2double(get(hObj,'String'));
  end

  function filteredit_callback(hObj, event)
    Config.settings.threshold.ThreshParams.Wallis.args{2} = ...
      str2double(get(hObj,'String'));
    Gui.handles.right.callbacks.slider();
  end

  function trackmodelpopup_callback(hObj, event)
    num = get(hObj, 'Value');
    strlist = get(hObj,'String');
    str = strlist{num};
    model_char = GetModelChar(str);
    Config.settings.mt_end_model = model_char;
  end

  function track_callback(varargin)
    TrackingMainFunc('Track');
  end
  
end

