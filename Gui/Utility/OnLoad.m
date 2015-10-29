function OnLoad(FileName)
%ONLOAD Summary of this function goes here
%   Detailed explanation goes here

global Config Data Gui

set(Gui.handles.left.popup, 'String', FileName);
num_channels = length(get(Gui.handles.left.popup, 'String'));
if Data.Input.General.MtStackNum > num_channels
  Data.Input.General.MtStackNum = num_channels;
  set(Gui.handles.left.popup, 'Value', Data.Input.General.MtStackNum);
  Gui.handles.left.callbacks.setmtchannel();
else
  set(Gui.handles.left.popup, 'Value', Data.Input.General.MtStackNum);
end;

% frame = get(Gui.handles.left.slider, 'Value');
set(Gui.handles.left.slider, 'Max', numel(Data.TirfInput.Stack{1}));
set(Gui.handles.right.slider, 'Max', numel(Data.TirfInput.Stack{1}));
set(Gui.handles.right.slider2, 'Max', numel(Data.TirfInput.Stack{1}));


Gui.handles.left.callbacks.slider()


end

