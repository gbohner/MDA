function varargout = config_gui(varargin)
% CONFIG_GUI MATLAB code for config_gui.fig
%      CONFIG_GUI, by itself, creates a new CONFIG_GUI or raises the existing
%      singleton*.
%
%      H = CONFIG_GUI returns the handle to a new CONFIG_GUI or the handle to
%      the existing singleton*.
%
%      CONFIG_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONFIG_GUI.M with the given input arguments.
%
%      CONFIG_GUI('Property','Value',...) creates a new CONFIG_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before config_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to config_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help config_gui

% Last Modified by GUIDE v2.5 02-Jun-2014 11:31:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @config_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @config_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before config_gui is made visible.
function config_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to config_gui (see VARARGIN)
global Data

chan=size(Data.TirfInput.Stack,2);
if chan==2
rawImg=Data.TirfInput.Stack{1,2};
else
rawImg=Data.TirfInput.Stack{1,1};    
end    
%rawImg=evalin('base','b');
handles.data=zeros(512,512,100);
for i=1:100
    handles.data(:,:,i)=rawImg{i};
end

handles.avImg=handles.data;

axes(handles.axes1);
imagesc(handles.avImg(:,:,2));
% set(handles.axes1,'CLimMode','manual');
Clims=get(handles.axes1,'CLim');
handles.Clims=[1.12*Clims(1,1),0.85*Clims(1,2)];
imagesc(handles.avImg(:,:,2),handles.Clims);
axis equal tight;
colorbar;

% Choose default command line output for config_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes config_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = config_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in apply_button.
function apply_button_Callback(hObject, eventdata, handles)
% hObject    handle to apply_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

window=round(get(handles.window_slider,'value'));
mask=ones(1,window)/window;

pos_size = get(handles.figure1,'Position');
user_response = questdlg(['Apply ' num2str(window) ' frame averaging?']);
switch user_response
case {'No'}
    
case 'Yes'
global Data Gui

chan=size(Data.TirfInput.Stack,2);
for n=1:chan
rawImg=Data.TirfInput.Stack{1,n};

for i=1:size(rawImg,2)
    handles.data(:,:,i)=rawImg{i};
end


handles.avImg=shiftdim(handles.data,1);
handles.avImg=convn(handles.avImg,mask,'valid');
handles.avImg=shiftdim(handles.avImg,2);
handles.avImg=uint16(handles.avImg);
%
newfile=[Data.TirfInput.Info{1,n}(1,1).Filename '_' num2str(window) '_Av.tif'];
saveastiff(handles.avImg,newfile,1);
%
for j=1:size(handles.avImg,3)
    imgOut{j}= handles.avImg(:,:,j);
end
Data.TirfInput.Stack{1,n}=imgOut;
end

maxlim=max(size(imgOut));
set(Gui.handles.left.slider, 'Max',maxlim);
set(Gui.handles.right.slider, 'Max',maxlim);
set(Gui.handles.right.slider2, 'Max',maxlim);
delete(handles.figure1)
end

% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pos_size = get(handles.figure1,'Position');
user_response = questdlg('Confirm Cancel?');
switch user_response
case {'No'}
    
case 'Yes'
       delete(handles.figure1)
end


% --- Executes on button press in preview_button.
function preview_button_Callback(hObject, eventdata, handles)
% hObject    handle to preview_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
window=round(get(handles.window_slider,'value'));
mask=ones(1,window)/window;
handles.avImg=shiftdim(handles.data,1);
handles.avImg=convn(handles.avImg,mask,'valid');
handles.avImg=shiftdim(handles.avImg,2);
frame=round(get(handles.frame_slider,'value'));
axes(handles.axes1);
aa=handles.avImg(:,:,frame);
XLims=get(gca,'XLim');
YLims=get(gca,'YLim');
imagesc(aa,handles.Clims);
set(gca,'XLim',XLims,'YLim',YLims);
colorbar;

if isfield(handles,'polygon')
hold on
polygon=handles.polygon;
polygon=floor(polygon);
h=plot([polygon(:,1)],[polygon(:,2)], 'Color','b');
hold off

line_scan=[];

for count=1:length(polygon(:,1))-1

  x1=polygon(count,1);
  y1=polygon(count,2);
  x2=polygon(count+1,1);
  y2=polygon(count+1,2);

  %points for the segmented lines
  xpoints = linspace(x1,x2);
  n = max(size(xpoints));
  
  ypoints = linspace(y1,y2,n); %match up the points
  xpoints = floor(xpoints);
  ypoints = floor(ypoints);
    
  for j = 1:n
    brightness = aa(ypoints(:,j),xpoints(:,j)); %switch x and y
    line_scan = [line_scan, brightness];
  end 
  
end
   
plot(handles.axes2,line_scan)

else
end

guidata(hObject, handles);

% --- Executes on slider movement.
function window_slider_Callback(hObject, eventdata, handles)
% hObject    handle to window_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
window=round(get(handles.window_slider,'value'));
set(handles.window_txt,'string',num2str(window));



% --- Executes during object creation, after setting all properties.
function window_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to window_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function window_txt_Callback(hObject, eventdata, handles)
% hObject    handle to window_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of window_txt as text
%        str2double(get(hObject,'String')) returns contents of window_txt as a double


% --- Executes during object creation, after setting all properties.
function window_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to window_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function frame_slider_Callback(hObject, eventdata, handles)
% hObject    handle to frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

max=size(handles.avImg,3);
frame=round(get(handles.frame_slider,'value'));
if frame > max
    frame=max;
end    
axes(handles.axes1);
XLims=get(gca,'XLim');
YLims=get(gca,'YLim');
set(gca,'XLim',XLims,'YLim',YLims);
aa=handles.avImg(:,:,frame);
imagesc(aa,handles.Clims);
set(gca, 'XLimMode', 'manual', 'YLimMode', 'manual');
colorbar;

if isfield(handles,'polygon')
hold on
polygon=handles.polygon;
polygon=floor(polygon);
plot([polygon(:,1)],[polygon(:,2)], 'Color','b');
hold off
set(gca,'XLim',XLims,'YLim',YLims);
line_scan=[];

for count=1:length(polygon(:,1))-1

  x1=polygon(count,1);
  y1=polygon(count,2);
  x2=polygon(count+1,1);
  y2=polygon(count+1,2);

  %points for the segmented lines
  xpoints = linspace(x1,x2);
 n=100;
  % n = max(size(xpoints));
  
  ypoints = linspace(y1,y2,n); %match up the points
  xpoints = floor(xpoints);
  ypoints = floor(ypoints);
    
  for j = 1:n
    brightness = aa(ypoints(:,j),xpoints(:,j)); %switch x and y
    line_scan = [line_scan, brightness];
  end 
  
end
   
plot(handles.axes2,line_scan)

handles.line=line_scan;
else
end
   guidata(hObject, handles); 

% --- Executes during object creation, after setting all properties.
function frame_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
%set(handles.frame_slider,'Max',size(handles.data,3));

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on button press in reset_push.
function reset_push_Callback(hObject, eventdata, handles)
% hObject    handle to reset_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cla(handles.axes2,'reset')

frame=round(get(handles.frame_slider,'value'));
axes(handles.axes1);
aa=handles.avImg(:,:,frame);
% imagesc(handles.avImg(:,:,frame),handles.Clims);
% colorbar;

hold on
polygon=ginput2(2);
polygon=floor(polygon);
h=plot([polygon(:,1)],[polygon(:,2)], 'Color','b');
hold off
handles.polygon=polygon;
line_scan=[]; %creating the empty list


for count=1:length(polygon(:,1))-1

  x1=polygon(count,1);
  y1=polygon(count,2);
  x2=polygon(count+1,1);
  y2=polygon(count+1,2);

  %points for the segmented lines
  xpoints = linspace(x1,x2);
  n = max(size(xpoints));
  
  ypoints = linspace(y1,y2,n); %match up the points
  xpoints = floor(xpoints);
  ypoints = floor(ypoints);
    
  for j = 1:n
    brightness = aa(ypoints(:,j),xpoints(:,j)); %switch x and y
    line_scan = [line_scan, brightness];
  end 
  
end
  
plot(handles.axes2,line_scan) %now switching to axes2

guidata(hObject, handles); %updates the handles


% --- Executes on button press in plot_button.
function plot_button_Callback(hObject, eventdata, handles)
% hObject    handle to plot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%sets the line
frame=round(get(handles.frame_slider,'value'));
aa=handles.avImg(:,:,frame);
axes(handles.axes1);
% imagesc(aa,handles.Clims);
% colorbar;

hold on
polygon=ginput2(2);
polygon=floor(polygon);
h=plot([polygon(:,1)],[polygon(:,2)], 'Color','b');
hold off
handles.polygon=polygon;
line_scan=[]; %creating the empty list


for count=1:length(polygon(:,1))-1

  x1=polygon(count,1);
  y1=polygon(count,2);
  x2=polygon(count+1,1);
  y2=polygon(count+1,2);

  %points for the segmented lines
  xpoints = linspace(x1,x2);
  n=100;
  %n = max(size(xpoints));
  
  ypoints = linspace(y1,y2,n); %match up the points
  xpoints = floor(xpoints);
  ypoints = floor(ypoints);
   
  for j = 1:n
    brightness = aa(ypoints(:,j),xpoints(:,j)); %switch x and y
    line_scan = [line_scan, brightness];
  end 
  
end
  
plot(handles.axes2,line_scan) %now switching to axes2


guidata(hObject, handles); %updates the handles


function snr_txt_Callback(hObject, eventdata, handles)
% hObject    handle to window_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of window_txt as text
%        str2double(get(hObject,'String')) returns contents of window_txt as a double
     

% --- Executes during object creation, after setting all properties.
function snr_txt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to snr_txt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in snr_calc.
function snr_calc_Callback(hObject, eventdata, handles)
% hObject    handle to snr_calc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes2);
[peakx,~]=ginput2(1);
peakx=floor(peakx);
peak=[];

polygon=handles.polygon;
line_scan=[];

 x1=polygon(1,1);
  y1=polygon(1,2);
  x2=polygon(2,1);
  y2=polygon(2,2);

  %points for the segmented lines
  xpoints = linspace(x1,x2);
  n = 100;
  
  ypoints = linspace(y1,y2,100); %match up the points
  xpoints = floor(xpoints);
  ypoints = floor(ypoints);
  
  for frame=1:size(handles.avImg,3)
  aa=handles.avImg(:,:,frame);
  for j = 1:n
    brightness = aa(ypoints(:,j),xpoints(:,j)); %switch x and y
    if (j >= peakx-7) && (j <= peakx+7)
        if (j >= peakx-3) && (j <= peakx+3)
        peak=[peak,brightness];
        end
    else
      line_scan = [line_scan, brightness];
    end
  end 
  end
[bkgnd,sd] = normfit(line_scan);
maximum=mean(peak);
sig=maximum-bkgnd;
snr=sig/sd;
set(handles.snr_txt,'string',num2str(snr));


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in helpbutton.
function helpbutton_Callback(hObject, eventdata, handles)
% hObject    handle to helpbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
helpdlg(sprintf('Moving Av: Select number of frames to average over. Press Preview.\nSNR: Plot Line, click two points across MT. Av SNR, click on peak in profile.\nRe-click Av SNR after changing moving av size.'));