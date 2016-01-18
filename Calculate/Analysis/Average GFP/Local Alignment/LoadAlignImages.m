function [ output_args ] = LoadAlignImages( input_args )
%LOADALIGNIMAGES Summary of this function goes here
%   Detailed explanation goes here

global Config

%Choose alignment images
  [fname,pathname] = uigetfile([Config.analysis.averagegfp.DirRoot '\*.tif'], 'Select MT channel bead/grid image');
  if ischar(fname)
      template = imread(fullfile(pathname,fname));
      Config.analysis.averagegfp.bead_im.mt = template;
  end

  [mname,pathname] = uigetfile([pathname '\*.tif'], 'Select GFP channel bead/grid image');
  if ischar(mname)
      image = imread(fullfile(pathname,mname));
      Config.analysis.averagegfp.bead_im.gfp = image;
  end

end

