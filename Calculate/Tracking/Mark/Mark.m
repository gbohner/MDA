function ManualData = Mark()
%MARK Mark microtubules to be tracked by hand

global Config Data Gui

%Creates the struct in which marking (and later tracking) information will be stored for each MT
ManualData = struct('seed', [], 'frames', [], 'ori', [], 'points', [], 'thresh', []);

%Sets gui elements for marking visible
set_markers_visibility('on');
set(Gui.handles.right.slider2, 'Value', get(Gui.handles.left.slider,'Max'));
Gui.handles.right.callbacks.slider2();

set(Gui.handles.right.slider2_apply,'String','Set frames')


% Waiting for the user to set frames for the tracking on the two sliders
waitfor(Gui.handles.right.slider2_apply,'String');

% If user clicked, sets frames in the struct
ManualData.frames = [floor(get(Gui.handles.right.slider, 'Value')), ...
                     floor(get(Gui.handles.right.slider2, 'Value'))];
   
% User has to mark 4 points (minus end, seed minus, seed plus, plus end)
[x, y] = getline(Gui.handles.right.axes);

%Corrects the user marked values by the rectangle used for enlarging
if ~isempty(Gui.data.right.rect)
   rect = Gui.data.right.rect;
   x=x+rect(1)-1;
   y=y+rect(2)-1;
end

%Calculates seed values and microtubule orentations.
ManualData.seed = [x(3) y(3)];
ori = [x(4)-x(3), y(4)-y(3)];
ori = ori/norm(ori,2);
ManualData.ori = ori;

%Uses linspace2d to linearly interpolate points inbetween marked points
points_minus = linspace2d([x(1) y(1)],[x(2) y(2)],floor(norm([x(2),y(2)]-[x(1),y(1)])));
points_seed = linspace2d([x(2) y(2)],[x(3) y(3)],floor(norm([x(3),y(3)]-[x(2),y(2)])));
points_plus = linspace2d([x(3) y(3)],[x(4) y(4)],floor(norm([x(4),y(4)]-[x(3),y(3)])));
        
points = [points_minus(1:end-1,:); points_seed(1:end-1,:); points_plus];

%Save calculated points in the struct
ManualData.points = points;
ManualData.points_seed = points_seed;
ManualData.iscat = [0 0];

%Save struct as a new element to Data.Track.ToTrack
Data.Track.ToTrack{end+1} = ManualData;

%Showing filtered image and waiting for user to set threshold
if Gui.state.threshold == 0   
   set(Gui.handles.right.slider2_apply,'String','Set Thresh')
   
   set(Gui.handles.middle.chbthreshold, 'Value', 1);
   Gui.handles.middle.callbacks.chbthreshold();
   Gui.handles.right.callbacks.slider();

   waitfor(Gui.handles.right.slider2_apply,'String');
   
   ManualData.thresh = Config.settings.threshold.ThreshParams.Threshold;
   
   set(Gui.handles.middle.chbthreshold, 'Value', 0);
   Gui.handles.middle.callbacks.chbthreshold();
else
   set(Gui.handles.right.slider2_apply,'String','Set Thresh')
   Gui.handles.right.callbacks.slider();
   
   waitfor(Gui.handles.right.slider2_apply,'String');
   
   ManualData.thresh = Config.settings.threshold.ThreshParams.Threshold;
end


set_markers_visibility('off');

function set_markers_visibility(str)
   set(Gui.handles.right.slider2,'Visible',str);
   set(Gui.handles.right.slider2_edit,'Visible',str);
   set(Gui.handles.right.slider2_apply,'Visible',str);   
   if strcmp(str,'on')
     Gui.state.marking = 1;
   else
     Gui.state.marking = 0;
   end
end

end