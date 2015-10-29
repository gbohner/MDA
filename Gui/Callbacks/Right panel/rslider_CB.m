function rslider_CB( value )
%RSLIDER_CB Summary of this function goes here
%   Detailed explanation goes here

global Config Data Gui

value = floor(value);

set(Gui.handles.right.slider_edit,'String',num2str(value));


%Check if file loaded
   if ~isfield(Data,'TirfInput') return; %#ok<SEPEX>
   end

if Gui.state.tracking == 0 && ...
      ~strcmp(get(Gui.handles.right.slider2_apply,'String'),'Set Thresh')

   num = get(Gui.handles.left.popup, 'Value');
   if ~isempty(Gui.data.right.rect)
      rect = Gui.data.right.rect;
      image = Data.TirfInput.pop(num, value, rect);
   else
      image = Data.TirfInput.pop(num, value);      
   end
   
   if Gui.state.threshold
      thr = Threshold(image);
      image = thr.DoThreshold(Config.settings.threshold.ThreshParams);
   end
elseif strcmp(get(Gui.handles.right.slider2_apply,'String'),'Set Thresh')
   num = get(Gui.handles.left.popup, 'Value');
   image = Data.TirfInput.pop(num, value);
   thr = Threshold(image);
   image = thr.DoThreshold(Config.settings.threshold.ThreshParams);
   Data.Track.current.frame = Data.Track.ToTrack{end}.frames(1);
   Data.Track.ToTrack{end}.thresh = Config.settings.threshold.ThreshParams.Threshold;
   image_bw = thr.DynamicMarked();
   imrgb = ones([size(image) 3]);
   imr = imrgb;
   imr(:,:,2:3) = -1;
   image_rgb = 0.7*imrgb.*repmat(double(image)/65535.0,[1,1,3]) + ...
      0.3* imr.*repmat(double(image_bw),[1,1,3]);
   image = image_rgb;
   image(image<0) = 0;
   if ~isempty(Gui.data.right.rect)
      rect = Gui.data.right.rect;
      image = image(rect(2):rect(2)+rect(4)-1, rect(1):rect(1)+rect(3)-1, :);
   end  
elseif Gui.state.tracking == 1
   if Gui.state.threshold
      image = Data.Track.current.thr{1}.output;
   else
      image = Data.Track.current.image;
   end
   
   if ~isempty(Gui.data.right.rect)
      rect = Gui.data.right.rect;
      image = image(rect(2):rect(2)+rect(4)-1, rect(1):rect(1)+rect(3)-1);
   end    
end

maxlim = max(size(image));
if isnan(maxlim) || maxlim <= 1
   maxlim = 100;
end
set(Gui.handles.right.axes, 'XLim', [1 maxlim], 'YLim', [1 maxlim]);

Gui.handles.right.image = ...
   imshow(image, 'Parent', Gui.handles.right.axes);
   
   

end

