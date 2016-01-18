function [ output_args ] = CalcMtFitGoodness( varargin )
%CALCMTFITGOODNESS Summary of this function goes here
%   Detailed explanation goes here

global pic bw;


% %get path where file was started and add to path
% DirThis = [fileparts( mfilename('fullpath') ) filesep];
% addpath(genpath(DirThis));

if numel(varargin) == 1
  DirRoot = varargin{1};
  
else

  DirRoot = uigetdir([],'Choose folder to alter the Filament_Data files in.');
  if DirRoot == 0
    return;
  end

end

folders = regexp(genpath(DirRoot),';','split');

% workbar(0,'Progress','CalcMtFitGoodness....');

for n = 1:numel(folders)-1

%     workbar(n/(numel(folders)-1),'Progress','CalcMtFitGoodness....');
    
    
   s = what(folders{n});
   if numel(s) == 0
         continue;
   end

   fildata = [];
   for i1 = 1:numel(s.mat)
     try
      if strcmp(s.mat{i1}(1:19),'trackedFilamentData')
         fildata = [fildata i1];
      end
     end
   end

   s.mat = s.mat(fildata);

   for m = 1:numel(s.mat)
     a = load([s.path '\' s.mat{m}]);
     
     if isfield(a.Filament, 'Cods')
         display([num2str(n) '/' num2str(numel(folders)-1) '  the current item has been skipped']);
       continue;
     end
     
     display([num2str(n) '/' num2str(numel(folders)-1) '  calculating CoD...']);
     
     fit_model = a.Config.settings.mt_end_model;
     pixelsize = a.Data.Input.General.PixelSize;
     
     a.Filament.Cods = NaN(size(a.Filament.Results,1), 2);
     a.Filament.EndFitData = cell(size(a.Filament.Results,1), 2);
     
     for i2 = 1:size(a.Filament.Results,1)
       
       pic = a.CropImsMtEnd{i2};
       
       pic = imresize(pic, a.Config.analysis.getgfpdata.croppixelsize/a.Data.Input.General.PixelSize);
       
       fitori = a.Filament.Results(i2,8);
       
       if strcmp(fit_model,'u')
         l_guess = [3000, 3000];
       else
         l_guess = [30,30];
       end
       
       guess = struct('obj', 1, 'model', fit_model, 'x', round((size(pic)+1)/2), 'o', fitori,...
                      'h',max(double(pic(:))),'w',200/pixelsize,'l',l_guess);

       params = struct('background', mean2(pic(pic<2*min(min(pic)))) ,'display',1, ...
                  'options', struct('MaxIter', 400, 'MaxFunEvals', 600, 'TolX', 1e-6, 'TolFun', 1e-6, 'JacobMult', []));

       params.object_width = a.Config.settings.threshold.ThreshParams.Deconv.fwhm / (2*sqrt(2*log(2)));
       params.fit_size = 4 * params.object_width;
       
       
       pic = double(pic);
       bw = im2bw(pic/max(max(pic)),0.7);
       
       [v,CoD] = Fit2D(fit_model, guess, params);
       
       a.Filament.Cods(i2,2) = CoD;
       a.Filament.EndFitData{i2,2} = v;
       
     end
     
     save([s.path '\' s.mat{m}],'-struct','a');
                
   end
   
end

end

