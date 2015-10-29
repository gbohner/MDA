function chbrect_CB( state )
%CHBRECT Summary of this function goes here
%   Detailed explanation goes here

global Config Gui

if (state == 1)
    Gui.state.rect = 1;
else
    Gui.state.rect = 0;
end


end

