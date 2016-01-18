function AlignParams = SetLocalAlign( Filament, FilID, index, cropsize, pixelsize, croppixelsize, AlignParams )
%SETLOCALALIGN Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
  error('Too few arguments');
end

if nargin < 6
  warning('Cropsize and/or pixelsize not set, using default 32 pixels.');
  cropsize = 32; %pixels
  pixelsize = 120; %nm
  croppedpixelsize = 25;
end

if nargin < 7
  
  AlignParams = struct('bead_im',struct('gfp',[],'mt',[]),...
                       'filpos',[],...
                       'Twarp',[],...
                       'rho',[],...
                       'settings',struct('levels', 1, 'noi', 100, 'transform', 'homography')...
                       );

%Choose alignment images
  [fname,pathname] = uigetfile('*.tif', 'Select new FIXED image');
  if ischar(fname)
      template = imread(fullfile(pathname,fname));
%       figure; imshow(template);
  end

  [mname,pathname] = uigetfile([pathname '\*.tif'], 'Select image to be ALIGNED');
  if ischar(mname)
      image = imread(fullfile(pathname,mname));
%       figure; imshow(image);
  end
  
AlignParams.bead_im.mt = template;
AlignParams.bead_im.gfp = image;
  
end  
  
%Crop images based on microtubule end position

CropSize = cropsize / pixelsize;
Enlarge = pixelsize / croppixelsize;

template = subpixcrop(AlignParams.bead_im.mt, Filament.PosEnd(index,:)/pixelsize, CropSize, Enlarge);
image = subpixcrop(AlignParams.bead_im.gfp, Filament.PosEnd(index,:)/pixelsize, CropSize, Enlarge);

%calculate transformation matrix
  levels= AlignParams.settings.levels;
  noi= AlignParams.settings.noi;
  transform= AlignParams.settings.transform;  

  [Twarp, im, results] = ecc2(image, template, levels, noi, transform);
  
  AlignParams.rho = results(end).rho;
  
  if AlignParams.rho >= 0.8
    AlignParams.Twarp = Twarp;
  else
    disp('Skipped alignment');
  end

end

