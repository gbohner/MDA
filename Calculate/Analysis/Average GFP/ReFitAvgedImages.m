function NewAvgedImages = ReFitAvgedImages( AvgedImages, models)
%REFITWITHOLD Summary of this function goes here
%   Detailed explanation goes here

global Config;

if nargin < 2
    models{1} = 'u';
    models{2} = 'u';
end

MT_cropsize = 1600; %cropped image's size in nm. you get MT_cropsize * MT_cropsize image for fit.
MT_cropsize = MT_cropsize/2;

GFP_cropsize = 3000;
GFP_cropsize = GFP_cropsize/2;

for i = 1:numel(AvgedImages)
    AvgIm = AvgedImages{i};
    Config = AvgIm.Config;
    
    AvgIm.mt.model = models{1};
    AvgIm.gfp.model = models{2};
        
      [AvgIm.mt.fit,  AvgIm.mt.cod ] = DoFitting('mt');
      [AvgIm.gfp.fit, AvgIm.gfp.cod] = DoFitting('gfp');

      %Calculate distance between gfp and mt's end position along the mt
      AvgIm.posdiff = AvgIm.mt.fit.x(:).value - AvgIm.gfp.fit.x(:).value;

      ori = [cos(AvgIm.mt.fit.o.value) sin(AvgIm.mt.fit.o.value)];

      AvgIm.posdiff = AvgIm.posdiff' * ori';
      AvgIm.posdiff = AvgIm.posdiff * Config.analysis.getgfpdata.croppixelsize;

      %Convert values to easily understandable ones
      wpx = AvgIm.pixelsize; %pixel size of fitted images

      %Create structs, then fill them up
      AvgIm.mt.fit_result = struct('x0',[],'ori',NaN,'psf',NaN,'w',NaN,'h',NaN,...
        'A', NaN, 'tau',NaN, 'bg', NaN);
      AvgIm.gfp.fit_result = struct('x0',[],'ori',NaN,'psf',NaN,'w',NaN,'h',NaN,...
        'A', NaN, 'tau',NaN, 'bg', NaN);

      AvgIm.mt.fit_result.x0 = AvgIm.mt.fit.x(1:2).value; % in pixels
      AvgIm.mt.fit_result.ori = AvgIm.mt.fit.o.value/pi*180; %in degrees
      AvgIm.mt.fit_result.psf = AvgIm.mt.fit.w(1).value * wpx; %in nm
      try
        AvgIm.mt.fit_result.w = AvgIm.mt.fit.w(2).value * wpx; %in nm
      end
      AvgIm.mt.fit_result.h = AvgIm.mt.fit.h.value; % in AU   
      if strcmp(models{1},'u')
        AvgIm.mt.fit_result.A = AvgIm.mt.fit.l(2).value * wpx; % in AU
        AvgIm.mt.fit_result.tau = AvgIm.mt.fit.l(1).value * wpx; % in nm
      end

      AvgIm.gfp.fit_result.x0 = AvgIm.gfp.fit.x(1:2).value; % in pixels
      AvgIm.gfp.fit_result.ori = AvgIm.gfp.fit.o.value/pi*180; %in degrees
      AvgIm.gfp.fit_result.psf = AvgIm.gfp.fit.w(1).value * wpx; %in nm
      try
        AvgIm.gfp.fit_result.w = AvgIm.gfp.fit.w(2).value * wpx; %in nm
      end
      AvgIm.gfp.fit_result.h = AvgIm.gfp.fit.h.value; % in AU   
      if strcmp(models{2},'u')
        AvgIm.gfp.fit_result.A = AvgIm.gfp.fit.l(2).value * wpx; % in AU
        AvgIm.gfp.fit_result.tau = AvgIm.gfp.fit.l(1).value * wpx; % in nm
      elseif strcmp(models{2},'c')
        AvgIm.gfp.fit_result.tau = (1/AvgIm.gfp.fit.l(1).value) * wpx;
      elseif strcmp(models{2},'a')
        AvgIm.gfp.fit_result.lat = AvgIm.gfp.fit.l(1).value;
      end


      %% Calculating and plotting 1D stuff

      if ~exist('h3','var')
        h3 = figure('Position',[30 30,640 640]); 
      else
        figure(h3);
      end

      %Get fit images
      [mtfitim, gfpfitim] = PlotAvgFit(AvgIm, 1);

      %Get 1D plots of mt and gfp, parallel and perpendicular, original and fit for each
      mt_orig_1d_along = GetLineScan(AvgIm.mt.im_nobg, AvgIm.mt.fit.x(:).value', AvgIm.mt.fit.o.value', AvgIm.pixelsize);
      mt_fit_1d_along = GetLineScan(mtfitim, AvgIm.mt.fit.x(:).value', AvgIm.mt.fit.o.value', AvgIm.pixelsize);
      mt_orig_1d_cross = GetLineScan(AvgIm.mt.im_nobg, AvgIm.mt.fit.x(:).value', AvgIm.mt.fit.o.value' + pi/2, AvgIm.pixelsize);
      mt_fit_1d_cross = GetLineScan(mtfitim, AvgIm.mt.fit.x(:).value', AvgIm.mt.fit.o.value' + pi/2, AvgIm.pixelsize);

      gfp_orig_1d_along = GetLineScan(AvgIm.gfp.im_nobg, AvgIm.mt.fit.x(:).value', AvgIm.mt.fit.o.value', AvgIm.pixelsize);
      gfp_fit_1d_along = GetLineScan(gfpfitim, AvgIm.mt.fit.x(:).value', AvgIm.mt.fit.o.value', AvgIm.pixelsize);
      gfp_orig_1d_cross = GetLineScan(AvgIm.gfp.im_nobg, AvgIm.mt.fit.x(:).value', AvgIm.mt.fit.o.value' +pi/2, AvgIm.pixelsize);
      gfp_fit_1d_cross = GetLineScan(gfpfitim, AvgIm.mt.fit.x(:).value', AvgIm.mt.fit.o.value'+pi/2, AvgIm.pixelsize);
        
      AvgIm.mt.linescan.orig.axial.d = mt_orig_1d_along(:,1);
      AvgIm.mt.linescan.orig.axial.i = mt_orig_1d_along(:,2);
      AvgIm.mt.linescan.fit.axial.d = mt_fit_1d_along(:,1);
      AvgIm.mt.linescan.fit.axial.i = mt_fit_1d_along(:,2);
      AvgIm.mt.linescan.orig.lateral.d = mt_orig_1d_cross(:,1);
      AvgIm.mt.linescan.orig.lateral.i = mt_orig_1d_cross(:,2);
      AvgIm.mt.linescan.fit.lateral.d = mt_fit_1d_cross(:,1);
      AvgIm.mt.linescan.fit.lateral.i = mt_fit_1d_cross(:,2);
      
      AvgIm.gfp.linescan.orig.axial.d = gfp_orig_1d_along(:,1);
      AvgIm.gfp.linescan.orig.axial.i = gfp_orig_1d_along(:,2);
      AvgIm.gfp.linescan.fit.axial.d = gfp_fit_1d_along(:,1);
      AvgIm.gfp.linescan.fit.axial.i = gfp_fit_1d_along(:,2);
      AvgIm.gfp.linescan.orig.lateral.d = gfp_orig_1d_cross(:,1);
      AvgIm.gfp.linescan.orig.lateral.i = gfp_orig_1d_cross(:,2);
      AvgIm.gfp.linescan.fit.lateral.d = gfp_fit_1d_cross(:,1);
      AvgIm.gfp.linescan.fit.lateral.i = gfp_fit_1d_cross(:,2);

      subplot(2,2,1); hold off;
      plot(mt_orig_1d_along(:,1), mt_orig_1d_along(:,2)); hold on;
      plot(mt_fit_1d_along(:,1), mt_fit_1d_along(:,2),'r');
      subplot(2,2,2); hold off;
      plot(mt_orig_1d_cross(:,1), mt_orig_1d_cross(:,2)); hold on;
      plot(mt_fit_1d_cross(:,1), mt_fit_1d_cross(:,2),'r');
      subplot(2,2,3); hold off;
      plot(gfp_orig_1d_along(:,1), gfp_orig_1d_along(:,2)); hold on;
      plot(gfp_fit_1d_along(:,1), gfp_fit_1d_along(:,2),'r');
      subplot(2,2,4); hold off;
      plot(gfp_orig_1d_cross(:,1), gfp_orig_1d_cross(:,2)); hold on;
      plot(gfp_fit_1d_cross(:,1), gfp_fit_1d_cross(:,2),'r');

      %%

      NewAvgedImages{i} = AvgIm;
    
    
end

close(h3);

function [v,l] = DoFitting(str)
      if strcmp(str,'mt')
         fit_model = models{1};
         useim = AvgIm.mt.im_nobg;
         fitori = AvgIm.orientation;
         
%          oriplusvec = round([cos(fitori), sin(fitori)] * 5);

         mid = (size(useim)+1)/2; % - oriplusvec;
         maximum = max(max(double(useim(mid(1)-20:mid(1)+20,mid(2)-20:mid(2)+20))));
         newsize = min([MT_cropsize / AvgIm.pixelsize, mid-1,size(useim)-mid-1]); %40
         useim = useim(mid(1)-newsize:mid(1)+newsize, mid(2)-newsize:mid(2)+newsize); % don't fit whole image, cause seed
         toadd = abs(mid - newsize)-1;
      else
         fit_model = models{2};
         fitori = AvgIm.orientation;
         
         useim = AvgIm.gfp.im_nobg;
         
         mid = (size(useim,1)+1)/2;
         maximum = max(max(double(useim(mid-20:mid+20,mid-20:mid+20))));
         newsize = min(GFP_cropsize / AvgIm.pixelsize, mid-1); %40
         useim = useim(mid-newsize:mid+newsize, mid-newsize:mid+newsize); % don't fit whole image, cause seed
         toadd = abs(mid - newsize)-1;
         
         maximum = max(max(double(useim)));
      end
      
      global pic bw;
      
      pic = double(useim);
      bw = im2bw(pic/max(max(pic)),0.7);
      
      pixelsize = Config.PixSize;
      griddensity = Config.PixSize/AvgIm.pixelsize;
      
      
      if strcmp(fit_model,'u')
        if strcmp(str,'mt')
          l_guess = [3000, 3000];
        else
          l_guess = [10, 100];
        end
        [v,l,c] = Fit2D(fit_model, struct('obj', 1, 'model', fit_model, 'x', (size(pic)+1)/2, 'o', fitori,...
                    'mtLattice',3*mean2(pic)/max(max(pic)),'h',maximum,'w',200/pixelsize*griddensity,'l',l_guess),  ...
                struct('background', mean2(pic(pic<0.2*max(max(pic)))),'fit_size',(size(pic,1)-1)/2 ,'display',1, ...
                'options', struct('MaxIter', 400, 'MaxFunEvals', 600, 'TolX', 1e-6, 'TolFun', 1e-6, 'JacobMult', [])));
      else
        [v,l,c] = Fit2D(fit_model, struct('obj', 1, 'model', fit_model, 'x', (size(pic)+1)/2, 'o', fitori,...
                    'mtLattice',3*mean2(pic)/max(max(pic)),'h',maximum,'w',450/pixelsize*griddensity), ...
                struct('background', mean2(pic),'fit_size',(size(pic,1)-1)/2 ,'display',1, ...
                'options', struct('MaxIter', 200, 'MaxFunEvals', 1000, 'TolX', 1e-6, 'TolFun', 1e-6, 'JacobMult', [])));
      end
      
      
      v.x = v.x + toadd;
      
      
   end


end

