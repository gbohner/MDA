function mda
%MDA Starts the Microtubule Detection and Analyzer program
%   Initiates global variables (used for storing all data and settings)
%   Adds all files and folders to Matlab path in the folder containing this file


%Determine if MDA is already open, if so, ask if user wants to restart
h_fig = findall(0, 'Name', 'Microtubule Dynamics Analyzer');
if ~isempty(h_fig)
  choose = questdlg('An instance of MDA is already open. Do you want to restart the program?',...
              'Close previous instance','Yes','No','No');
  if strcmp(choose,'No')
    return;
  else
    delete(h_fig);
    mda();
    return;
  end
end

clear global -regexp *;

%Initiate global variables
global Config Data Gui;


%get path where mda.m was started
DirRoot = [fileparts( mfilename('fullpath') ) filesep];
addpath(genpath(DirRoot));

% %Creates a debug folder
% if ~isdir('C:\debug')
%    mkdir('C:\debug');
% end

%Initiates basic settings. Can all be later changed in Configuration menu.
set_default_settings();

%Initiates the gui, that will take care of all functionality via button callbacks.
mda_gui();

end

