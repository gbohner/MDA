function GFPmov()
%% Load files

[FileName,PathName] = uigetfile('\trackedFilamentData*.mat', 'Select tracking file','MultiSelect','on');
% GFPfile=[pathname GFPfile];  

ToLoad = {};
      if iscell(FileName)
         for r1 = 1:numel(FileName)
            ToLoad(r1) = strcat(PathName, FileName(r1));
         end
      else
         ToLoad{1} = strcat(PathName, FileName);
      end
for fi= 1:max(size(ToLoad))
    
load(ToLoad{fi});
%% Get file info
A = exist('CropImsGfpEnd','var');

no_frame = max(size(CropImsGfpEnd));    % Get the number of images in the file
%no_frame = 10;
N=max(size(CropImsGfpEnd{1,1}));
GFPstack=zeros(N,N,no_frame);% Preallocate the array
if A==1
    GFP2stack=GFPstack;
end    
% s=warning('off','all');
%% Read frames and transform
for iFrame = 1:no_frame
GFPstack(:,:,iFrame)=CropImsGfpEnd{iFrame,1};       % Read GFP frame from stack
imagesc(CropImsGfpEnd{iFrame,1});figure(gcf);
title(strcat('Frame=',num2str(iFrame),'/',num2str(no_frame)));
drawnow
end
GFPstack=uint16(GFPstack);
newfile=[strtok(ToLoad{fi},'.') '_GFP.tif'];
saveastiff(GFPstack,newfile,1); %Save array as tif
%% If channel 3 exists
if A==1
for iFrame = 1:no_frame
GFP2stack(:,:,iFrame)=CropImsGfp2End{iFrame,1};       % Read GFP frame from stack
imagesc(CropImsGfp2End{iFrame,1});figure(gcf);
title(strcat('Frame=',num2str(iFrame),'/',num2str(no_frame)));
drawnow
end
GFP2stack=uint16(GFP2stack);
newfile=[strtok(ToLoad{fi},'.') '_Chn3.tif'];
saveastiff(GFP2stack,newfile,1); %Save array as tif
end
end
