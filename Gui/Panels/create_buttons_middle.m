function [ output_args ] = create_buttons_middle( parent, pos, scale )
%CREATE_PANEL_MIDDLE Summary of this function goes here
%   Detailed explanation goes here

global Config Gui 

%Custom settings in middle

h_chbslider = uicontrol('Parent', parent,'Style','checkbox','String','Joint','Value',1,...
   'Position',pos + [48 52 45 15]*scale, 'Callback',@chbslider_callback);

thrimage = imread([fileparts( mfilename('fullpath') ) filesep 'Images' filesep 'thresh.bmp']);
h_chbthreshold = uicontrol('Parent', parent,'Style','togglebutton','Value',0,...
   'Position',pos + [10 420 25 25]*scale, 'Callback',@chbthreshold_callback);
set(h_chbthreshold,'CData',imresize(thrimage,scale));

rectimage = imread([fileparts( mfilename('fullpath') ) filesep 'Images' filesep 'rect.bmp']);
h_chbrect = uicontrol('Parent', parent,'Style','togglebutton','Value',0,...
   'Position',pos + [10 450 25 25]*scale, 'Callback',@chbrect_callback);
set(h_chbrect,'CData',imresize(rectimage,scale));

Gui.handles.middle.chbslider = h_chbslider;
Gui.handles.middle.chbthreshold = h_chbthreshold;
Gui.handles.middle.chbrect = h_chbrect;
Gui.handles.middle.callbacks.chbthreshold = @chbthreshold_callback;


%Callback functions
   function chbslider_callback(varargin)
      state = get(Gui.handles.middle.chbslider, 'Value');
      chbslider_CB(state);
   end
   function chbthreshold_callback(varargin)
      state = get(Gui.handles.middle.chbthreshold, 'Value');
      chbthreshold_CB(state);
      Gui.handles.right.callbacks.slider();
   end
   function chbrect_callback(varargin)
      state = get(Gui.handles.middle.chbrect, 'Value');
      chbrect_CB(state);
   end

end

