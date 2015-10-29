function chbthreshold_CB( state )
%CHBTHRESHOLD_CB Summary of this function goes here
%   Detailed explanation goes here

global Config Gui

if (state == 1)
    Gui.state.threshold = 1;
else
    Gui.state.threshold = 0;
end

end

