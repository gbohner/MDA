function [ output_args ] = create_panel_analyse( parent, pos, scale )
%PANEL_TRACK Summary of this function goes here
%   Detailed explanation goes here

global Config Gui

h_anpanel = uipanel('Parent', parent, 'Units', 'pixels', 'Position', pos, 'Visible', 'on',...
   'Title','Analyse');

%Button for loading tracks
  h_choosetracks = uicontrol('Parent', h_anpanel,'Style','pushbutton','String','Choose tracks',...
   'Units', 'pixels', 'Position', [20 117 120 23]*scale,'Callback',@choosetracks_callback,...
   'Visible','on');
 
  h_diralldata = uicontrol('Parent', h_anpanel,'Style','pushbutton','String','Folder',...
   'TooltipString',Config.analysis.choosetracks.DirRoot,...
   'Units', 'pixels', 'Position', [20 86 40 20]*scale,'Callback',@dir_callback,...
   'Visible','on','HorizontalAlignment','right');
 
  h_alldata_name = uicontrol('Parent', h_anpanel,'Style','edit','String',Config.analysis.choosetracks.savename,...
   'Units', 'pixels', 'Position', [65 86 75 20]*scale,'Callback',@alldata_name_callback,...
   'FontSize',8,'Visible','on');
 
  h_getgfp = uicontrol('Parent', h_anpanel,'Style','pushbutton','String','Get GFP data',...
   'Units', 'pixels', 'Position', [20 64 120 20]*scale,'Callback',@getgfp_callback,...
   'Visible','on');

  %Access command line to do on the fly advanced changes
  h_tools = uicontrol('Parent', h_anpanel,'Style','pushbutton','String','Command Line',...
   'Units', 'pixels', 'Position', [20 5 120 30]*scale,'Callback',@tools_callback,...
   'Visible','on');

 
 
 %Label for threshold setting
  h_diraveragegfp = uicontrol('Parent', h_anpanel,'Style','pushbutton','String','Folder',...
   'TooltipString',Config.analysis.averagegfp.DirRoot,...
   'Units', 'pixels', 'Position', [160 115 40 25]*scale,'Callback',@dir_callback,...
   'Visible','off','HorizontalAlignment','right');

  h_imname = uicontrol('Parent', h_anpanel,'Style','edit','String',Config.analysis.averagegfp.imname,...
    'Units', 'pixels', 'Position', [205 115 105 25]*scale,'Callback',@imname_callback,...
    'Visible','on');
 
  h_mtmodelpopup = uicontrol('Parent', h_anpanel,'Style','popupmenu',...
    'String',ModelLibrary( 'MT_end' ),...
   'Units', 'pixels', 'Position', [160 80 70 30]*scale,'Callback',@mtmodelpopup_callback);
 
   h_gfpmodelpopup = uicontrol('Parent', h_anpanel,'Style','popupmenu',...
    'String',ModelLibrary( 'GFP_end' ),...
   'Units', 'pixels', 'Position', [240 80 70 30]*scale,'Callback',@gfpmodelpopup_callback);
 
 %Button for tracking
  
  h_chbavgim = uicontrol('Parent', h_anpanel,'Style','checkbox','String','Save avg','Value',Config.analysis.averagegfp.saveavgims,...
   'Position',[160 65 65 15]*scale, 'Callback',@chb_callback);
  h_chbfitim = uicontrol('Parent', h_anpanel,'Style','checkbox','String','Save fit','Value',Config.analysis.averagegfp.savefitims,...
   'Position',[160 48 65 15]*scale, 'Callback',@chb_callback);
  h_chbvid = uicontrol('Parent', h_anpanel,'Style','checkbox','String','Save vid','Value',Config.analysis.averagegfp.savevideos,...
   'Position',[160 30 65 15]*scale, 'Callback',@chb_callback);
  h_avgalign = uicontrol('Parent', h_anpanel,'Style','pushbutton','String','Align',...
   'Units', 'pixels', 'Position', [230 60 80 20]*scale,'Callback',@avgalign_callback,...
   'Visible','on', 'TooltipString','Select recorded alignment images from the microtubule and the gfp channel to identify necessary warp');
h_preselection = uicontrol('Parent', h_anpanel,'Style','pushbutton','String','Pre-selection',...
   'Units', 'pixels', 'Position', [230 33 80 25]*scale,'Callback',@preselection_callback,...
   'Visible','on','TooltipString','Selects and saves tracking episodes, with option to then average'); 
  h_averagegfp = uicontrol('Parent', h_anpanel,'Style','pushbutton','String','Average GFP',...
   'Units', 'pixels', 'Position', [230 5 80 25]*scale,'Callback',@averagegfp_callback,...
   'Visible','on','TooltipString','Selects tracking episodes and averages'); 
 
h_chbpreselect = uicontrol('Parent', h_anpanel,'Style','checkbox','String','Use Pre-selection','Value',Config.analysis.averagegfp.preselect,...
   'Position',[310 5 140 15]*scale, 'Callback',@chbpreselect_callback,'TooltipString','Tick box to load and average previously saved tracking episodes');
 
 %Callback functions
 
 function tools_callback(hObj,event)
    keyboard
  end
 
  function choosetracks_callback(varargin)
    [Config.analysis.choosetracks.tracks, Config.analysis.choosetracks.DirRoot] = ...
      ChooseTracks();
  end

  function alldata_name_callback(hObj,event)
    Config.analysis.choosetracks.savename = get(hObj,'String');
  end

  function getgfp_callback(varargin)
    DirCur = GetGFPdata();
    %CalcMtFitGoodness(DirCur); % Was only needed to convert very old data
    LoadTracksToAlign();
  end

  function mtmodelpopup_callback(hObj, event)
    num = get(hObj, 'Value');
    strlist = get(hObj,'String');
    str = strlist{num};
    model_char = GetModelChar(str);
    Config.analysis.averagegfp.models.mt = model_char;
  end

  function gfpmodelpopup_callback(hObj, event)
    num = get(hObj, 'Value');
    strlist = get(hObj,'String');
    str = strlist{num};
    model_char = GetModelChar(str);
    Config.analysis.averagegfp.models.gfp = model_char;
  end

  function dir_callback(hObj, event)
    switch hObj
      case h_diraveragegfp
        newdir = uigetdir(Config.workdir);
        if newdir == 0
          warndlg('No folder was chosen, stopping function.');
          return;
        end
        Config.analysis.averagegfp.DirRoot = newdir;
        set(h_diraveragegfp,'TooltipString',Config.analysis.averagegfp.DirRoot);
%       case h_dirflexalign
%         newdir = uigetdir(Config.workdir);
%         if newdir == 0
%           warndlg('No folder was chosen, stopping function.');
%           return;
%         end
%         Config.analysis.flexalign.DirSave = newdir;
%         set(h_dirflexalign,'String',newdir(max(1,end-23):end));
%         set(h_dirflexalign,'TooltipString',newdir);
      case h_diralldata
        newdir = uigetdir(Config.workdir);
        if newdir == 0
          warndlg('No folder was chosen, stopping function.');
          return;
        end
        Config.analysis.choosetracks.DirSave = newdir;
        set(h_diralldata,'TooltipString',newdir);
    end
  end

  function imname_callback(hObj, event)
    Config.analysis.averagegfp.imname = get(hObj,'String');
  end

  function chb_callback(hObj, event)
    switch hObj
      case h_chbavgim
        Config.analysis.averagegfp.saveavgims = get(hObj,'Value');
      case h_chbfitim
        Config.analysis.averagegfp.savefitims = get(hObj,'Value');
      case h_chbvid
        Config.analysis.averagegfp.savevideos = get(hObj,'Value');
      case h_chbsubavgs
        Config.analysis.flexalign.subavgs = get(hObj,'Value');
      case h_chbnormalise
        Config.analysis.flexalign.normalise = get(hObj,'Value');
    end
  end

  function avgalign_callback(hObj, event)
    LoadAlignImages();
    Config.analysis.averagegfp.choose_align = 1;    
  end

 function preselection_callback(hObj, event)
    PreSelectionForAvgGFP();
  end

  function averagegfp_callback(hObj, event)
   preselect=Config.analysis.averagegfp.preselect;
      if preselect==1
          %%%load tracks dialogue
          PreSelectedTracks={};
          [FileName,PathName,FilterIndex] = uigetfile([Config.workdir '\*.mat'],'Load Tracks_selected_for_AverageGFP','MultiSelect','off');
          load(strcat(PathName, FileName));
      AverageGFP(PreSelectedTracks);    
      else    
      AverageGFP();
      end
  end

   function chbpreselect_callback(hObj, event)
            Config.analysis.averagegfp.preselect = get(hObj,'Value');
   end


  function butgrp_callback(hObj,event)
    Config.analysis.flexalign.mode = get(get(hObj,'SelectedObject'),'String');
  end

  function alignsavename_callback(hObj,event)
    Config.analysis.flexalign.savename = get(hObj,'String');
  end

  function flexalign_callback(hObj,event)
    FlexAlign();
  end

end