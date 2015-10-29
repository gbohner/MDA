function btnalign_CB()
%BTNMAIN_CB Summary of this function goes here
%   Detailed explanation goes here

global Config Data;

calc_twarp = 1;

if ~isempty(Config.settings.Align.Twarp)
  choice = questdlg('You''ve already set an alignment, do you want to change it?','Change alignment','Yes','No','No');
  if strcmp(choice,'No')
    calc_twarp = 0;
  end
end

if calc_twarp
  %Choose alignment images
  [fname,pathname] = uigetfile('*.tif', 'Select new FIXED image');
  if ischar(fname)
      template = imread(fullfile(pathname,fname));
      figure; imshow(template);
  end

  [mname,pathname] = uigetfile([pathname '\*.tif'], 'Select image to be ALIGNED');
  if ischar(mname)
      image = imread(fullfile(pathname,mname));
      figure; imshow(image);
  end
  
  %Run alignment algorithm
  levels=1;
  noi=100;
  transform='homography';  

  [Twarp, warpedImage, results] = ecc2(image, template, levels, noi, transform);

  residual = (warpedImage - mean(warpedImage(:))) - (template - mean(template(:)));

  CoD = 1 - sum( residual(:).^2 ) / sum( ( warpedImage(:) - mean( warpedImage(:) ) ).^2 );

%   if CoD < 0
%     warndlg('Alignment didn''t work properly, try again with different images');
%     return;
%   else
    Config.settings.Align.Twarp = Twarp;
    Config.settings.Align.CoD = CoD;
    Config.settings.Align.image = image;
    Config.settings.Align.template = template;
    Config.settings.Align.params.levels = levels;
    Config.settings.Align.params.noi = noi;
    Config.settings.Align.params.transform = transform;
%   end

end

choice = questdlg('Do you want to align the loaded stacks (if there are), something else, or nothing?', ...
          'Alignment method', 'Loaded', 'Something', 'Nothing', 'Loaded');
       
if strcmp(choice, 'Loaded')
  FileName = Data.Input.General.FileName;
  PathName = Data.Input.General.PathName;
  ToLoad = {};
  if iscell(FileName)
     for r1 = 1:numel(FileName)
        ToLoad(r1) = strcat(PathName, FileName(r1));
     end
  else
     warndlg('Less than 2 files are loaded');
  end
  
  choice2 = questdlg('Which file to transform (gfp)?', 'Choose GFP', FileName{1}, FileName{2}, FileName{1});
  
  if strcmp(choice2, FileName(1))
    [AlignedGFPstack, newfilename] = WarpAlign(Config.settings.Align.Twarp, ToLoad{1}, ToLoad{2});
    Data.TirfInput.Stack{1} = AlignedGFPstack;
    Data.Input.General.FileName{1} = newfilename;
  else
    [AlignedGFPstack, newfilename] = WarpAlign(Config.settings.Align.Twarp, ToLoad{2}, ToLoad{1});
    Data.TirfInput.Stack{2} = AlignedGFPstack;
    Data.Input.General.FileName{2} = newfilename;
  end
  
elseif strcmp('choice','Something')
  WarpAlign(Config.settings.Align.Twarp);
end


end

