function LineScan = GetLineScan( image, pos, ori, pixelsize, method, stepsize )
%GET1DLINESCAN Summary of this function goes here
%   Detailed explanation goes here

global Config;

if nargin < 6 || isempty(stepsize)
  stepsize = 1;
end
if nargin < 5 || isempty(method)
  method = ['bi' Config.analysis.advanced.interpmethod];
end
if nargin < 5 || isempty(method)
  pixelsize = 25;
end

step = [cos(ori), sin(ori)] *stepsize; % steps are towards plus end.
numplus = 0;
numminus = 0;

calcpos = pos;
LineScan = 0;

%specify points to find values in
cont = 1;
while cont %plus
  numplus = numplus + 1;
  newpos = pos + numplus .* step;
  
  try
    a = image(round(newpos(1)),round(newpos(2)));
    LineScan = [LineScan; numplus * stepsize];
    calcpos = [calcpos; newpos];
  catch
    cont = 0;
  end
end

cont = 1;
while cont %minus
  numminus = numminus - 1;
  newpos = pos + numminus * step;
  
  try
    a = image(round(newpos(1)),round(newpos(2)));
    LineScan = [numminus * stepsize; LineScan];
    calcpos = [newpos; calcpos];
  catch
    cont = 0;
  end
end



LineScan(:,1) = LineScan(:,1)*pixelsize;

%use improfile to get values for specified points
LineScan(:,2) = improfile(image, calcpos(:,1)',calcpos(:,2)',method);

