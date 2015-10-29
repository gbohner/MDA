function [ output_args ] = Create1DAvgLinescan( tif_stack_mt, tif_stack_gfp, AvgIm )
%CREATE1DAVGLINESCAN Summary of this function goes here
%   Detailed explanation goes here

MtStack = {};
GfpStack = {};

croprange = (-5000:25:5000)';

for i1 = 1: numel(imfinfo(tif_stack_mt))
  MtStack{i1} = imread(tif_stack_mt, i1);
  GfpStack{i1} = imread(tif_stack_gfp, i1);
end

mt_avgims{1} = double(MtStack{1});
gfp_avgims{1} = double(GfpStack{1});

mt_linescans = nan(length(croprange), numel(MtStack)+1);
gfp_linescans = nan(length(croprange), numel(MtStack)+1);

mt_linescans(:,1) = croprange;
gfp_linescans(:,1) = croprange;

for i1 = 1:numel(MtStack)
  if i1>1
    mt_avgims{i1} = (mt_avgims{i1-1} * (i1-1) + double(MtStack{i1})) / i1;
    gfp_avgims{i1} = (gfp_avgims{i1-1} * (i1-1) + double(GfpStack{i1})) / i1;
  end
  
%   figure(3);
%   imagesc(gfp_avgims{i1});
  
  %Get linescans based on fit data;
  mt_orig_1d_along = GetLineScan(mt_avgims{i1}, AvgIm.mt.fit.x(:).value', AvgIm.mt.fit.o.value', AvgIm.pixelsize);
  gfp_orig_1d_along = GetLineScan(gfp_avgims{i1}, AvgIm.mt.fit.x(:).value', AvgIm.mt.fit.o.value', AvgIm.pixelsize);

  
  nb = findnearest(mt_orig_1d_along(:,1), croprange);
  mt_linescans(nb, i1+1) = mt_orig_1d_along(:,2);
  nb = findnearest(gfp_orig_1d_along(:,1), croprange);
  gfp_linescans(nb, i1+1) = gfp_orig_1d_along(:,2);
end

%Save tif image stacks of averaging process
  saveastiffopt.color = false;
  saveastiffopt.comp = 'no';
  saveastiffopt.append = true;
  for i174 = 1:numel(mt_avgims)
    saveastiff2(uint16(mt_avgims{i174}), [tif_stack_mt(1:end-4) '_AveragingVideo.tif'], saveastiffopt);
  end
  for i174 = 1:numel(gfp_avgims)
    saveastiff2(uint16(gfp_avgims{i174}), [tif_stack_gfp(1:end-4) '_AveragingVideo.tif'], saveastiffopt);
  end
  
  
%Save as an excel the linescans
  xlswrite([tif_stack_mt(1:end-4) '_AveragingVideo.xls'], mt_linescans);
  xlswrite([tif_stack_gfp(1:end-4) '_AveragingVideo.xls'], gfp_linescans);
  
  
%Create the linescan plots
  figure(3);
  Video_mt_ls = [];
  for i174 = 1:numel(mt_avgims)
      plot(-mt_linescans(:,1), mt_linescans(:, i174+1));
      ylim([min(min(mt_linescans(:, 2:end))),  max(max(mt_linescans(:, 2:end)))]);      
      xlabel('Distance from microtubule end (nm)')
      ylabel('Intensity (au)')
      frame = getframe(gcf);
      Video_mt_ls(:,:,:,end+1) = uint8(frame.cdata);
  end
  Video_mt_ls = Video_mt_ls(:,:,:,2:end);
  Video_gfp_ls = [];
  for i174 = 1:numel(mt_avgims)
      plot(-gfp_linescans(:,1), gfp_linescans(:, i174+1));
      ylim([min(min(gfp_linescans(:, 2:end))),  max(max(gfp_linescans(:, 2:end)))]);
      xlabel('Distance from microtubule end (nm)')
      ylabel('Intensity (au)')
      frame = getframe(gcf);
      Video_gfp_ls(:,:,:,end+1) = uint8(frame.cdata);
  end
  Video_gfp_ls = Video_gfp_ls(:,:,:,2:end);

%Save videos
  [FileName, PathName] = uiputfile('*.avi','Set video filename');
  framerate = inputdlg('Video frame rate');
  framerate = str2num(framerate{1});
  vw = VideoWriter([PathName FileName(1:end-4) '_gfp' FileName(end-3:end)]);
  vw.FrameRate = framerate;
  open(vw);
  writeVideo(vw,uint8(Video_gfp_ls));
  close(vw);
  vw = VideoWriter([PathName FileName(1:end-4) '_mt' FileName(end-3:end)]);
  vw.FrameRate = framerate;
  open(vw);
  writeVideo(vw,uint8(Video_mt_ls));
  close(vw);
  
%Create the movies
  figure(2);
  Video_mt = [];
  for i174 = 1:numel(mt_avgims)
      imagesc((0:256)*25/1000, (0:256)*25/1000, imrotate(mt_avgims{i174},180));
      axis square
      xlabel('\mum')
      ylabel('\mum')
      frame = getframe(gcf);
      Video_mt(:,:,:,end+1) = uint8(frame.cdata);
  end
  Video_gfp = [];
  for i174 = 1:numel(mt_avgims)
      imagesc((0:256)*25/1000, (0:256)*25/1000, imrotate(gfp_avgims{i174},180));
      axis square
      xlabel('\mum')
      ylabel('\mum')
      frame = getframe(gcf);
      Video_gfp(:,:,:,end+1) = uint8(frame.cdata);
  end

%Save videos
  [FileName, PathName] = uiputfile('*.avi','Set video filename');
  framerate = inputdlg('Video frame rate');
  framerate = str2num(framerate{1});
  vw = VideoWriter([PathName FileName(1:end-4) '_gfp' FileName(end-3:end)]);
  vw.FrameRate = framerate;
  open(vw);
  writeVideo(vw,uint8(Video_gfp));
  close(vw);
  vw = VideoWriter([PathName FileName(1:end-4) '_mt' FileName(end-3:end)]);
  vw.FrameRate = framerate;
  open(vw);
  writeVideo(vw,uint8(Video_mt));
  close(vw);

end

