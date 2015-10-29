function AvgGFPsortbySpeed(OldAvgedImages, growth_speed)

  global Config
  
  DirRoot = Config.workdir;
  imname = Config.analysis.averagegfp.imname;
  imname = [imname '_from_' num2str(growth_speed(1)) 'ummin_to_' num2str(growth_speed(2)) 'ummin_(' datestr(now,30) ')'];
  imname = [DirRoot filesep imname];
  models{1} = Config.analysis.averagegfp.models.mt;
  models{2} = Config.analysis.averagegfp.models.gfp;
  
  %Maximum cropsizes: 6.4 um.
  %If you're aligning as well, use < 5 um
  MT_cropsize = Config.analysis.averagegfp.MT_cropsize;
  GFP_cropsize = Config.analysis.averagegfp.GFP_cropsize;
  NewAlignThresh = Config.analysis.averagegfp.NewAlignThresh;

  MT_cropsize = MT_cropsize/2;
  GFP_cropsize = GFP_cropsize/2;
  
  AvgedImages = {};
  
  for i1 = 1:numel(OldAvgedImages)
    AvgIm = OldAvgedImages{i1};
    
    if AvgIm.growthSpeed < growth_speed(1) || AvgIm.growthSpeed > growth_speed(2)
      continue;
    end
    
    AvgIm.mt.model = models{1};
    AvgIm.gfp.model = models{2};
    [AvgIm.mt.fit,  AvgIm.mt.cod ] = DoFitting('mt');
    [AvgIm.gfp.fit, AvgIm.gfp.cod] = DoFitting('gfp');

    %Calculate distance between gfp and mt's end position along the mt
    AvgIm.posdiff = AvgIm.mt.fit.x(:).value - AvgIm.gfp.fit.x(:).value;

    ori = [-cos(AvgIm.mt.fit.o.value) -sin(AvgIm.mt.fit.o.value)];

    AvgIm.posdiff = AvgIm.posdiff' * ori';
    AvgIm.posdiff = AvgIm.posdiff * AvgIm.Config.analysis.getgfpdata.croppixelsize;

%               if strcmp(models{1},'e')
%                  %Add half of FWHM to posdiff, so it's counted from half maximum of gauss func
%                  AvgIm.posdiff = AvgIm.posdiff - AvgIm.mt.fit.w(1).value * 2*sqrt(2*log(2)) * AvgIm.Config.analysis.getgfpdata.croppixelsize;
%               end

    %Convert values to easily understandable ones
    AvgIm = create_fit_result(AvgIm);

    % Calculating and plotting 1D stuff
    AvgIm = create_linescans(AvgIm);
    
    AvgedImages{end+1} = AvgIm;
  end
    
  save([imname '_AveragedData.mat'], 'AvgedImages');
  exporttoexcel2(AvgedImages,[imname '_AveragedData.xls']);


  function [v,l] = DoFitting(str)
      if strcmp(str,'mt')
         fit_model = models{1};
         useim = AvgIm.mt.im_nobg;
         fitori = AvgIm.orientation;

         mid = (size(useim)+1)/2;
         maximum = max(max(double(useim(mid(1)-20:mid(1)+20,mid(2)-20:mid(2)+20))));
         newsize = min([MT_cropsize / AvgIm.Config.analysis.getgfpdata.croppixelsize, mid-1,size(useim)-mid-1]); %40
         useim = useim(mid(1)-newsize:mid(1)+newsize, mid(2)-newsize:mid(2)+newsize); % don't fit whole image, cause seed
         toadd = abs(mid - newsize)-1;
      else
         fit_model = models{2};
         fitori = AvgIm.orientation;
         
         useim = AvgIm.gfp.im_nobg;

         mid = (size(useim,1)+1)/2;
         maximum = max(max(double(useim(mid-20:mid+20,mid-20:mid+20))));
         newsize = min(GFP_cropsize / AvgIm.Config.analysis.getgfpdata.croppixelsize, mid-1); %40
         useim = useim(mid-newsize:mid+newsize, mid-newsize:mid+newsize); % don't fit whole image, cause seed
         toadd = abs(mid - newsize)-1;

         maximum = max(max(double(useim)));
      end

      global pic bw;

      pic = double(useim);
      bw = im2bw(pic/max(max(pic)),0.7);

      
      if strcmp(fit_model,'u')
        if strcmp(str,'mt')
          l_guess = [3000, 3000];
        else
          l_guess = [10, 100];
        end
        [v,l,c] = Fit2D(fit_model, struct('obj', 1, 'model', fit_model, 'x', (size(pic)+1)/2, 'o', fitori,...
                    'mtLattice',3*mean2(pic)/max(max(pic)),'h',maximum,'w',8,'l',l_guess),  ...
                struct('background', mean2(pic(pic<0.2*max(max(pic)))),'fit_size',(size(pic,1)-1)/2 ,'display',1, ...
                'options', struct('MaxIter', 1400, 'MaxFunEvals', 3600, 'TolX', 1e-6, 'TolFun', 1e-6, 'JacobMult', [])));
      else
        [v,l,c] = Fit2D(fit_model, struct('obj', 1, 'model', fit_model, 'x', (size(pic)+1)/2, 'o', fitori,...
                    'mtLattice',3*mean2(pic)/max(max(pic)),'h',maximum,'w',8), ...
                struct('background', mean2(pic),'fit_size',(size(pic,1)-1)/2 ,'display',1, ...
                'options', struct('MaxIter', 200, 'MaxFunEvals', 1000, 'TolX', 1e-6, 'TolFun', 1e-6, 'JacobMult', [])));
      end


      v.x = v.x + toadd;

  end

  function AvgIm = create_fit_result(AvgIm)
    wpx = AvgIm.pixelsize; %pixel size of fitted images
          
    %Create structs, then fill them up
    AvgIm.mt.fit_result = struct('x0',[],'ori',NaN,'psf',NaN,'w',NaN,'h',NaN,...
      'tau',NaN, 'bg', NaN);
    AvgIm.gfp.fit_result = struct('x0',[],'ori',NaN,'psf',NaN,'w',NaN,'h',NaN,...
      'tau',NaN, 'bg', NaN);

    AvgIm.mt.fit_result.x0 = AvgIm.mt.fit.x(1:2).value; % in pixels
    AvgIm.mt.fit_result.ori = AvgIm.mt.fit.o.value/pi*180; %in degrees
    AvgIm.mt.fit_result.psf = AvgIm.mt.fit.w(1).value * wpx; %in nm
    try
      AvgIm.mt.fit_result.w = AvgIm.mt.fit.w(2).value * wpx; %in nm
    end
    AvgIm.mt.fit_result.h = AvgIm.mt.fit.h.value; % in AU   
    if strcmp(models{1},'u')
      AvgIm.mt.fit_result.tau = AvgIm.mt.fit.l(1).value * wpx; % in nm
      AvgIm.mt.fit_result.h = AvgIm.mt.fit_result.h * wpx; %in AU, multiply by pixelsize, because h/tau must stay same
    end

    AvgIm.gfp.fit_result.x0 = AvgIm.gfp.fit.x(1:2).value; % in pixels
    AvgIm.gfp.fit_result.ori = AvgIm.gfp.fit.o.value/pi*180; %in degrees
    AvgIm.gfp.fit_result.psf = AvgIm.gfp.fit.w(1).value * wpx; %in nm
    try
      AvgIm.gfp.fit_result.w = AvgIm.gfp.fit.w(2).value * wpx; %in nm
    end
    AvgIm.gfp.fit_result.h = AvgIm.gfp.fit.h.value; % in AU   
    if strcmp(models{2},'u')
      AvgIm.gfp.fit_result.tau = AvgIm.gfp.fit.l(1).value * wpx; % in nm
      AvgIm.gfp.fit_result.h = AvgIm.gfp.fit_result.h * wpx; %in AU, multiply by pixelsize, because h/tau must stay same
    elseif strcmp(models{2}, 'v')
      AvgIm.gfp.fit_result.tau = AvgIm.gfp.fit.l(1).value * wpx; % in nm
      AvgIm.gfp.fit_result.lat = AvgIm.gfp.fit.l(2).value; %in AU
      AvgIm.gfp.fit_result.h = AvgIm.gfp.fit_result.h * wpx; %in AU, multiply by pixelsize, because h/tau must stay same
    elseif strcmp(models{2},'c')
      AvgIm.gfp.fit_result.tau = (1/AvgIm.gfp.fit.l(1).value) * wpx;
    elseif strcmp(models{2},'a')
      AvgIm.gfp.fit_result.lat = AvgIm.gfp.fit.l(1).value;
    end
  end

  function AvgIm = create_linescans(AvgIm)
    %Get fit images
    [mtfitim, gfpfitim] = PlotAvgFit(AvgIm, 1);

    %Get 1D plots of mt and gfp, axial and lateral, original and fit for each
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
  end


end