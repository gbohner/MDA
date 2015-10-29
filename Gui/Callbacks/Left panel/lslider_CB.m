function lslider_CB( value )
%LSLIDER_CB Summary of this function goes here
%   Detailed explanation goes here

global Config Data Gui;

   set(Gui.handles.left.slider_edit,'String',num2str(value));
   
   %Check if file loaded
   if ~isfield(Data,'TirfInput') return; %#ok<SEPEX>
   end
   
   %num = Data.Input.General.MtStackNum;
   num = get(Gui.handles.left.popup, 'Value');
   
   maxframe=max(size(Data.TirfInput.Stack{num}));
   %maxlim = max(size(Data.TirfInput.Stack{num}{value}));
   if value>maxframe
       value=maxframe;
   end    
   maxlim = max(size(Data.TirfInput.Stack{num}{value}));
   Gui.handles.left.image = ...
      imagesc(Data.TirfInput.Stack{num}{value}, 'Parent', Gui.handles.left.axes);
  set(Gui.handles.left.axes, 'XLim', [1 maxlim], 'YLim', [1 maxlim]);
	set(Gui.handles.left.image, 'ButtonDownFcn', Gui.handles.left.callbacks.btndwn)

   
   if ~isempty(Gui.data.right.rect)
      Gui.handles.left.rect = rectangle('Position',Gui.data.right.rect,...
         'Parent',Gui.handles.left.axes,'EdgeColor',[1 0 0], 'LineStyle', '--'); 
      drawnow;
   end
   
end

