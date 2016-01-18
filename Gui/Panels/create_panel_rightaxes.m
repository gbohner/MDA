function [ output_args ] = create_panel_rightaxes( parent, pos, scale )
%PANEL_TRACK Summary of this function goes here
%   Detailed explanation goes here

global Config Gui

%Dynamic panel on right
h_rpanel = uipanel('Parent', parent, 'Units', 'pixels', 'Position', pos, 'Visible', 'on',...
   'BorderType', 'none', 'BackgroundColor',Gui.general.panelbackground);
h_raxes = axes('Parent', h_rpanel, 'Units', 'pixels', 'Position', [50 100 384 384]*scale,...
   'HandleVisibility', 'on', 'NextPlot', 'replacechildren');
h_rpopup = uicontrol('Parent', h_rpanel,'Style','popupmenu','String',{'none'},...
   'Units', 'pixels', 'Position', [50 490 140 20]*scale,'Callback',@rpopup_callback);
h_rslider = uicontrol('Parent', h_rpanel,'Style','slider','Max',100,'Min',1,'Value',1,...
   'Units', 'pixels', 'Position', [50 50 344 20]*scale,...
   'SliderStep',[0.05 0.2], 'Visible','on');
addlistener(h_rslider,'ContinuousValueChange',@rslider_callback);
h_rslider_edit = uicontrol('Parent', h_rpanel,'Style','edit','String','1',...
   'Units', 'pixels', 'Position', [400 50 34 20]*scale,'Callback',@rslider_edit_callback);
h_rslider2 = uicontrol('Parent', h_rpanel,'Style','slider','Max',100,'Min',1,'Value',1,...
   'Units', 'pixels', 'Position', [50 20 344 20]*scale,...
   'SliderStep',[0.05 0.2], 'Visible','off','Callback',@rslider2_callback);
h_rslider2_edit = uicontrol('Parent', h_rpanel,'Style','edit','String','1',...
   'Units', 'pixels', 'Position', [400 20 34 20]*scale,'Callback',@rslider2_edit_callback, 'Visible','off');
h_rslider2_apply = uicontrol('Parent', h_rpanel,'Style','pushbutton','String','Apply','Value',1,...
   'Units', 'pixels', 'Position', [440 20 50 50]*scale,'Callback',@rslider2_apply_callback,...
   'Visible','off');
 
 h_rerase = uicontrol('Parent', h_rpanel,'Style','pushbutton','String','Erase','Value',1,...
   'Units', 'pixels', 'Position', [50 40 80 30]*scale,'Callback',@rerase_callback,...
   'Visible','off');
 
  h_rendadding = uicontrol('Parent', h_rpanel,'Style','pushbutton','String','Subaverages','Value',1,...
   'Units', 'pixels', 'Position', [364 490 70 25]*scale,'Callback',@radd_callback,...
   'Visible','off');
 
  h_raddclick = uicontrol('Parent', h_rpanel,'Style','pushbutton','String','Set by click','Value',1,...
   'Units', 'pixels', 'Position', [290 490 70 25]*scale,'Callback',@radd_callback,...
   'Visible','off');
 
  h_raddtime = uicontrol('Parent', h_rpanel,'Style','pushbutton','String','Set by time','Value',1,...
   'Units', 'pixels', 'Position', [216 490 70 25]*scale,'Callback',@radd_callback,...
   'Visible','off');
 
  h_reditbox1 = uicontrol('Parent', h_rpanel,'Style','edit','String',num2str(Config.analysis.averagegfp.skipdarkgfp),'Value',1,...
   'Units', 'pixels', 'Position', [290 520 70 25]*scale,'Callback',@redit_callback,...
   'Visible','off');
 
  h_reditbox2 = uicontrol('Parent', h_rpanel,'Style','edit','String','-3','Value',1,...
   'Units', 'pixels', 'Position', [364 520 70 25]*scale,'Callback',@redit_callback,...
   'Visible','off');
 
  h_reditbox2_label = uicontrol('Parent', h_rpanel,'Style','text','FontSize',10,'String','Set maxgfp/bg: ',...
   'Units', 'pixels', 'Position', [180 524 110 18]*scale,...
   'Visible','off', 'TooltipString','If there is not enough GFP intensity during a particular frame, it gets omitted from the average');
 
 
Gui.handles.right.panel = h_rpanel;
Gui.handles.right.axes = h_raxes;
Gui.handles.right.popup = h_rpopup;
Gui.handles.right.slider = h_rslider;
Gui.handles.right.slider_edit = h_rslider_edit;
Gui.handles.right.slider2 = h_rslider2;
Gui.handles.right.slider2_edit = h_rslider2_edit;
Gui.handles.right.slider2_apply = h_rslider2_apply;
Gui.handles.right.callbacks.slider = @rslider_callback;
Gui.handles.right.callbacks.slider2 = @rslider2_callback;
Gui.handles.right.erase = h_rerase;
Gui.handles.right.addclick = h_raddclick;
Gui.handles.right.addtime = h_raddtime;
Gui.handles.right.endadding = h_rendadding;
Gui.handles.right.editbox1 = h_reditbox1;
Gui.handles.right.editbox2 = h_reditbox2;
Gui.handles.right.editbox_label = h_reditbox2_label;

 function rslider_callback(varargin)
      value = get(Gui.handles.right.slider, 'Value');
      value = floor(value);
      rslider_CB(value);
      if Gui.state.marking
         if value>floor(get(Gui.handles.right.slider2, 'Value'))
            set(Gui.handles.right.slider2,'Value',value);
            rslider2_callback();
         end
      end
      if Gui.state.slider_joint
         set(Gui.handles.left.slider, 'Value',value);
         lslider_CB(value);
      end
   end
   function rslider_edit_callback(varargin)
      value = get(Gui.handles.right.slider_edit, 'String');
      value = floor(str2double(value));
      set(Gui.handles.right.slider,'Value',value);
      rslider_callback();
   end
   function rslider2_callback(varargin)
      value2 = get(Gui.handles.right.slider2, 'Value');
      value2 = floor(value2);
      set(Gui.handles.right.slider2_edit,'String',num2str(value2));
      if value2<ceil(get(Gui.handles.right.slider, 'Value'))
         set(Gui.handles.right.slider,'Value',value2);
         rslider_callback();
      end
   end
   function rslider2_edit_callback(varargin)
      value2 = get(Gui.handles.right.slider2_edit, 'String');
      value2 = floor(str2double(value2));
      set(Gui.handles.right.slider2,'Value',value2);
      rslider2_callback();
   end
   function rslider2_apply_callback(varargin)
      val = get(Gui.handles.right.slider2_apply,'String');
      set(Gui.handles.right.slider2_apply,'String',[val 'a']);
%       display(val);
   end
 
   function rpopup_callback(varargin)
      num = get(Gui.handles.right.popup, 'Value');
      type = get(Gui.handles.right.popup, 'String');
      type = type{num};
      
%       try
        switch Gui.mode
          case 'averagegfp'
            Gui.handles.display.averagegfp(type);
          case 'flexalign'
            Gui.handles.display.flexalign(type)
        end
%       catch Exc
%         warning('Data you want to plot is no longer available');
%       end
   end
 
   function rerase_callback(varargin)
    Gui.state.erase = 1;
    uiresume;
   end
 
 function redit_callback(hObj, event)
    %TODO
    if strcmp(Gui.mode, 'averagegfp')
      if hObj == h_reditbox1
        Config.analysis.averagegfp.skipdarkgfp = str2double(get(hObj,'String'));
      end
    end
   end

  function radd_callback(hObj, event)
    switch hObj
      case h_raddclick
        axes(Gui.handles.right.axes);
        [t, ~] = ginput(2);
        Config.analysis.flexalign.subaveragegfp.timeframes(:,end+1) = t;
      case h_raddtime
        t = zeros(2,1);
        t(1) = str2num(get(Gui.handles.right.editbox1,'String'));
        t(2) = str2num(get(Gui.handles.right.editbox2,'String'));
        Config.analysis.flexalign.subaveragegfp.timeframes(:,end+1) = t;
      case h_rendadding
        Gui.state.setsubavgtimeframes = 0;
    end
    uiresume;
  end

end

