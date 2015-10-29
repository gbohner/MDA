function Objects = trackbeads()
%TRACKBEADS Summary of this function goes here
%   Detailed explanation goes here

global Config Data;
Data.Track.current.frame = 343;
Data.Track.frames(2) = 349;

Objects = {};

h1 = figure;

while Data.Track.current.frame <= Data.Track.frames(2)

  im = Data.TirfInput.Stack{1}{max(Data.Track.current.frame+1,2)};
  
  bw = Image2Binary(im, ...
    struct('threshold',...
    mean2(im(im<min(im(:))*3)) ...
    * Config.settings.threshold.ThreshParams.Threshold,...
    'binary_image_processing','none')...
  );
  
  figure(h1); imshow(bw);
    title(Data.Track.current.frame);
  
  tic;
  [objects, params] = FindPointObj(im, bw);
  disp('RoughScanTime: '); toc;
  
  params.min_cod = 0;
  params.bead_model_char = 'p';
  
  global pic;
  pic = double(im);
  
  params.options = struct('MaxIter', 200, 'MaxFunEvals', 200, 'TolX', 1e-3,...
    'TolFun', 1e-3, 'JacobMult', []);
  
  tic;
  objects = BeadFineScan( objects, params );
  disp('FineScanTime: '); toc;
  
  objects = BeadInterpolateData(objects, params);
  
  objects = orderfields(objects);
  
  Objects{Data.Track.current.frame} = objects;
  
  Data.Track.current.frame = Data.Track.current.frame + 1;

end

