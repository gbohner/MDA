function [PsfAvg PsfErr PsfNum] = FindAvgPSF( Objects, CoDthresh )
%FINDAVGPSF Summary of this function goes here
%   Detailed explanation goes here

PSF = [];
CoD = [];

for i1 = 1:numel(Objects)
  if ~isempty(Objects{i1})
    PSF = [PSF, Objects{i1}.width(1,:)];
    CoD = [CoD, Objects{i1}.cods(1,:)];
  end
end

PSF = PSF(CoD>CoDthresh);

toFWHM = 2*sqrt(2*log(2));

PsfErr = std(PSF)/sqrt(numel(PSF)) *toFWHM;
PsfAvg = mean(PSF)*toFWHM;
PsfNum = numel(PSF);


end

