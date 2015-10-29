function [ output_args ] = create_panel_leftaxes( parent, pos, scale )
%CREATE_PANEL_LEFTAXES Summary of this function goes here
%   Detailed explanation goes here

global Gui Data

% Panel on left
h_lpanel = uipanel('Parent', parent, 'Units', 'pixels', 'Position', pos, 'Visible', 'on',...
   'BorderType', 'none', 'BackgroundColor',Gui.general.panelbackground);
h_laxes = axes('Parent', h_lpanel, 'Units', 'pixels', 'Position', [50 100 384 384]*scale, ...
   'HandleVisibility', 'on', 'NextPlot', 'replace');
h_lpopup = uicontrol('Parent', h_lpanel,'Style','popupmenu','String',{'none'},...
   'Units', 'pixels', 'Position', [50 490 140 20]*scale,'Callback',@lpopup_callback);
h_setmtchannel = uicontrol('Parent', h_lpanel,'Style','pushbutton','String','Set Tracked Channel',...
   'Units', 'pixels', 'Position', [200 490 140 20]*scale,'Callback',@setmtchannel_callback,...
   'Visible','on','HorizontalAlignment','left');
h_lslider = uicontrol('Parent', h_lpanel,'Style','slider','Max',100,'Min',1,'Value',1,...
   'Units', 'pixels', 'Position', [50 50 344 20]*scale, ...
   'SliderStep',[0.05 0.2]);
addlistener(h_lslider,'ContinuousValueChange',@lslider_callback);
h_lslider_edit = uicontrol('Parent', h_lpanel,'Style','edit','String','1',...
   'Units', 'pixels', 'Position', [400 50 34 20]*scale,'Callback',@lslider_edit_callback);

h_lprev = uicontrol('Parent', h_lpanel,'Style','pushbutton','String','Previous','Value',1,...
   'Units', 'pixels', 'Position', [50 40 80 30]*scale,'Callback',@lprev_callback,...
   'Visible','off');
 
h_lselect = uicontrol('Parent', h_lpanel,'Style','pushbutton','String','Select','Value',1,...
   'Units', 'pixels', 'Position', [202 40 80 30]*scale,'Callback',@lselect_callback,...
   'Visible','off');
 
h_lnext = uicontrol('Parent', h_lpanel,'Style','pushbutton','String','Next','Value',1,...
   'Units', 'pixels', 'Position', [354 40 80 30]*scale,'Callback',@lnext_callback,...
   'Visible','off');
 
h_lquit = uicontrol('Parent', h_lpanel,'Style','pushbutton','String','Quit','Value',1,...
   'Units', 'pixels', 'Position', [354 1 80 30]*scale,'Callback',@lquit_callback,...
   'Visible','off');
 
Gui.handles.left.panel = h_lpanel;
Gui.handles.left.axes = h_laxes;
Gui.handles.left.slider = h_lslider;
Gui.handles.left.slider_edit = h_lslider_edit;
Gui.handles.left.popup = h_lpopup;
Gui.handles.left.setmtchannel = h_setmtchannel;
Gui.handles.left.prev = h_lprev;
Gui.handles.left.select = h_lselect;
Gui.handles.left.next = h_lnext;
Gui.handles.left.quit = h_lquit;
Gui.handles.left.callbacks.btndwn = @laxes_buttondown_callback;
Gui.handles.left.callbacks.slider = @lslider_callback;
Gui.handles.left.callbacks.setmtchannel = @setmtchannel_callback;
 
%Callback functions
  function lslider_callback(varargin)
      value = get(Gui.handles.left.slider, 'Value');
      value = floor(value);
      lslider_CB(value);
      if Gui.state.slider_joint
         set(Gui.handles.right.slider, 'Value',value);
         rslider_CB(value);
      end
%       set_children_callback(Gui.handles.left.axes, @laxes_buttondown_callback)
   end
  function lslider_edit_callback(varargin)
      value = get(Gui.handles.left.slider_edit, 'String');
      value = floor(str2double(value));
      set(Gui.handles.left.slider,'Value',value);
      lslider_callback();
   end
 
  function laxes_buttondown_callback(varargin)
      if Gui.state.rect == 1
         try
            delete(Gui.handles.left.rect);
            drawnow
         end
         Gui.data.right.rect = floor(getrect(Gui.handles.left.axes));
         if Gui.data.right.rect(3) == 0
            Gui.data.right.rect(3) = 1;
         end
         if Gui.data.right.rect(4) == 0
            Gui.data.right.rect(4) = 1;
         end
%          hold on;
         Gui.handles.left.rect = rectangle('Position',Gui.data.right.rect,...
            'Parent',Gui.handles.left.axes,'EdgeColor',[1 0 0], 'LineStyle', '--'); 
         drawnow;
%          hold off;
         rslider_CB(get(Gui.handles.left.slider, 'Value'));
         set_children_callback(Gui.handles.left.axes, @laxes_buttondown_callback);
      end
   end
 
  function lpopup_callback(varargin)
      num = get(Gui.handles.left.popup, 'Value');
      %Data.Input.General.MtStackNum = num;
      lslider_callback();
  end
 
  function setmtchannel_callback(varargin)
      num = get(Gui.handles.left.popup, 'Value');
      set(Gui.handles.info.mtchannel, 'String', num2str(num));
      Gui.handles.info.callbacks.mtchannel(Gui.handles.info.mtchannel);
  end
 
  function lprev_callback(varargin)
    if Gui.state.iterator > 1
      Gui.state.iterator = Gui.state.iterator - 1;
      
      %Set Next back if it was already on end
      str = get(Gui.handles.left.next,'String');
      if strcmp(str,'End')
        set(Gui.handles.left.next,'String','Next');
      end
      
      uiresume;
      
    end
  end

  function lselect_callback(varargin)
    Gui.state.select = 1;
    uiresume;
  end

  function lnext_callback(varargin)
    str = get(Gui.handles.left.next,'String');
    if strcmp(str,'Next') || strcmp(str,'Accept')
      Gui.state.iterator = Gui.state.iterator + 1;
    elseif strcmp(str,'End')
      switch Gui.mode
        case 'averagegfp'
          Gui.state.averagegfp = 0;
        case 'flexalign'
          Gui.state.flexalign = 0;
      end
      set(Gui.handles.left.next,'String','Next');
    end
    
    uiresume;
      
  end
 
  function lquit_callback(varargin)
    Gui.state.select = 0;
    Gui.state.averagegfp = 0;
    Gui.state.choosetracks = 0;
    Gui.state.flexalign = 0;
    uiresume;
  end
end

