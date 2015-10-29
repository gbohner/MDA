function chbslider_CB( state )
%CHBSLIDER_CB Summary of this function goes here
%   Detailed explanation goes here

global Config Gui

if (state == 1)
    Gui.state.slider_joint = 1;
else
    Gui.state.slider_joint = 0;
end

end

