function varargout = mda_gui(varargin)
% MDA_GUI Main User Interface of MDA
%   This Gui creates all buttons and figures for user
%   input and display.
%
%   The Gui also handles numerous callback functions, 
%   inside this file appears only the basic functionality
%   of the corresponding callback, the more advanced 
%   functionalities are taken care of in separate function 
%   files in the Callbacks subfolder.

% (Leave a blank line following the help.)

global Gui;
%    Gui.general.panelbackground = [0.94 0.94 0.62];
    Gui.general.panelbackground = [0.7608, 0.8392, 0.8549];

%  Initialization tasks
scrsz = get(0,'ScreenSize');
scale = Gui.general.scale; 
h_figure = figure('MenuBar','none','Toolbar','none','Visible','on','Name','Microtubule Dynamics Analyzer',...
   'Position',[scrsz(3)/2-round(600*scale) scrsz(4)-round(730*scale)-50 round(1200*scale), round(730*scale)], 'CloseRequestFcn', @mda_close_callback,'Color',Gui.general.panelbackground);


% Construct the components

% Main menu on the top
h_tpanel = uipanel('Parent', h_figure, 'Units', 'pixels', 'Position', [0 550 1200 180]*scale, 'Visible', 'on',...
   'BorderType', 'none');
 
% Creating sub_panels divisions
create_panel_track(h_tpanel, [200 0 500 175]*scale, scale);
create_panel_analyse(h_tpanel, [700 0 500 175]*scale, scale);
create_panel_info(h_tpanel, [0 0 200 175]*scale, scale);

create_panel_leftaxes(h_figure, [200 0 500 550]*scale, scale);

create_panel_rightaxes(h_figure, [700 0 500 550]*scale, scale);

create_panel_side(h_figure, [0 0 200 550]*scale, scale);

create_buttons_middle(h_figure, [630 0 0 0]*scale, scale);


%  Initialization tasks
%% Gui setup

Gui.handles.figure = h_figure;
Gui.handles.figure_callback = @mda_close_callback;

Gui.state.slider_joint = 1;
Gui.state.threshold = 0;
Gui.state.tracking = 0;
Gui.state.marking = 0;

Gui.data.right.rect = [];


%%


%  Callbacks for MYGUI
   function mda_close_callback(varargin)
      if numel(varargin)>0 && strcmp(varargin{1},'Reset')
         clear global
         clear
         closereq
         mda
      else        
         answer = questdlg('Are you sure you want to quit?', 'Quit','Yes','No','No');
         if strcmp(answer,'Yes')
            clear global
            clear
            closereq
         end
      end
   end
  
   

%  Utility functions for MYGUI
   function change_children_visibility(hpanel, visibility)
      children = get(hpanel, 'Children');
      for r1 = 1:numel(children)
         set(children(r1), 'Visible',visibility);
      end
   end


  

end
