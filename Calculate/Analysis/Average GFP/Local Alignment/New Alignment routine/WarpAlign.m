function [AlignedGFPstack, newfile]=WarpAlign(Twarp,GFPfile,Cy5file)
%% Load files
if nargin~=3;
[Cy5file,pathname] = uigetfile('*.tif', 'Select FIXED (MT) image');
Cy5file=[pathname Cy5file];
GFPfile = uigetfile([pathname '\*.tif'], 'Select image to be ALIGNED (GFP)');
GFPfile=[pathname GFPfile];  
end

figure;

RawGFPstack=loadtiff(GFPfile);
Cy5stack=loadtiff(Cy5file);
%% Get file info
tiffInfo = imfinfo(GFPfile);  % Get the TIF file information
no_frame = numel(tiffInfo);    % Get the number of images in the file
%no_frame = 200;
N=tiffInfo(1,1).Width;
M=tiffInfo(1,1).Height;
AlignedGFPstack = RawGFPstack; % Preallocate the array
%warning('off','all');
%% Read frames and transform
for iFrame = 1:no_frame
RawGFPframe=RawGFPstack(:,:,iFrame);       % Read GFP frame from stack
Cy5frame=Cy5stack(:,:,iFrame);        % Read Cy5 frame from stack
AlignedGFPframe = spatial_interp(double(RawGFPframe), Twarp, 'cubic', 'homography', 1:N, 1:M);     % Transform frame and crop to original size
AlignedGFPframe = uint16(AlignedGFPframe);
AlignedGFPstack(:,:,iFrame)=AlignedGFPframe;    % Insert frame into array
imshowpair(AlignedGFPframe,Cy5frame);           % Display superimposed channels
title(strcat('Frame=',num2str(iFrame),'/',num2str(no_frame)));
drawnow
end
%%
%warning('on','all');
newfile=[GFPfile(1:end-4) '_Aligned.tif'];
saveastiff(AlignedGFPstack,newfile,1);   %Save array as tif

AlGFPstack = {};
for i1 = 1:size(AlignedGFPstack,3);
  AlGFPstack{i1} = AlignedGFPstack(:,:,i1);
end
AlignedGFPstack = AlGFPstack;

global Config;
if ~isempty(Config.settings.Align.Twarp)
  Align = Config.settings.Align;
  save([GFPfile '_AlignmentSettings.mat'], '-struct', 'Align');
end