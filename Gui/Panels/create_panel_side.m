function [ output_args ] = create_panel_side( parent, pos, scale )
%CREATE_PANEL_SIDE Summary of this function goes here
%   Detailed explanation goes here

global Config Gui

h_sidepanel = uipanel('Parent', parent, 'Units', 'pixels', 'Position', pos);
% h_btnmain = uicontrol('Parent', h_sidepanel,'Style','pushbutton','String','Load',...
%    'Units', 'pixels', 'Position', [0 0 200 80],'Callback',@btnmain_callback,...
%    'Visible','on');
h_btnconfig = uicontrol('Parent', h_sidepanel,'Style','pushbutton','String','Averaging and SNR',...
   'Units', 'pixels', 'Position', [0 80 200 80]*scale,'Callback',@btnconfig_callback,...
   'Visible','on');
h_btnpsf = uicontrol('Parent', h_sidepanel,'Style','pushbutton','String','Get PSF',...
   'Units', 'pixels', 'Position', [0 160 200 80]*scale,'Callback',@btnpsf_callback,...
   'Visible','on');
 
 Gui.handles.menu.panel = h_sidepanel;
Gui.handles.menu.button.config = h_btnconfig;
Gui.handles.menu.button.psf = h_btnpsf;


%Callbacks

   function btnconfig_callback(varargin)
      config_gui();
      
   end
   function btnpsf_callback(varargin)
      SaveDir = uigetdir();
      if SaveDir == 0
        warndlg('No folder was chosen, stopping function.');
        return;
      end
      Objects = trackbeads();
      save([SaveDir '\psf_file.mat'],'Objects');
      [PsfAvg, PsfErr, PsfNum] = FindAvgPSF(Objects, 0.92);
      save([SaveDir '\psf_vals.mat'],'PsfAvg','PsfErr','PsfNum');
   end

end

