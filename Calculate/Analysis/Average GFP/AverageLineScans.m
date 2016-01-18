function AveragedLineScan = AverageLineScans( AvgedImages, type, normalize, weighted )
%AVERAGELINESCANS Summary of this function goes here
%   Detailed explanation goes here


AverageLength = 5000; %nm

AveragedLineScan = struct('d','i','fit', 'nums');

i1 = 1;
while 1==1
    try
        stepsize = mean(diff(AvgedImages{i1}.mt.linescan.orig.axial.d));
        break;
    catch
        i1 = i1+1;
    end
end

AverageLength = floor(AverageLength./stepsize)*stepsize;

AveragedLineScan.d = (-AverageLength:stepsize:AverageLength)';

AveragedLineScan.nums = zeros(size(AveragedLineScan.d));
AveragedLineScan.i = zeros(size(AveragedLineScan.d));

AllLineScans = [];
AllWeights = [];

for i1 = 1:numel(AvgedImages)
    AvgIm = AvgedImages{i1};
    
    if isempty(AvgIm)
      continue;
    else
      AllLineScans = [AllLineScans, NaN(size(AveragedLineScan.d))];
    end
    
    CurrentLineScan = [];
    
    switch type
        case 'mt_axial'
            CurrentLineScan.d = AvgIm.mt.linescan.orig.axial.d; 
            CurrentLineScan.i = AvgIm.mt.linescan.orig.axial.i;
        case 'mt_lateral'
            CurrentLineScan.d = AvgIm.mt.linescan.orig.lateral.d; 
            CurrentLineScan.i = AvgIm.mt.linescan.orig.lateral.i;  
        case 'gfp_axial'
            CurrentLineScan.d = AvgIm.gfp.linescan.orig.axial.d; 
            CurrentLineScan.i = AvgIm.gfp.linescan.orig.axial.i;
        case 'gfp_lateral'
            CurrentLineScan.d = AvgIm.gfp.linescan.orig.lateral.d; 
            CurrentLineScan.i = AvgIm.gfp.linescan.orig.lateral.i;        
    end
    
    CurrentLineScan.d = CurrentLineScan.d(~isnan(CurrentLineScan.i));
    CurrentLineScan.i = CurrentLineScan.i(~isnan(CurrentLineScan.i));
    
    if normalize
      CurrentLineScan.i = CurrentLineScan.i/max(CurrentLineScan.i);
    end
    
    if weighted
      AllWeights(end+1) = AvgIm.length;
    else
      AllWeights(end+1) = 1;
    end
    
    pos = findnearest(CurrentLineScan.d, AveragedLineScan.d);  
    
    AllLineScans(pos, end) = CurrentLineScan.i;
    AveragedLineScan.nums(pos) = AveragedLineScan.nums(pos) + 1;
    
end

AllWeights = AllWeights / nansum(AllWeights);
AllLineScansWeighted = AllLineScans .* repmat(AllWeights, size(AllLineScans, 1), 1);
AveragedLineScan.i = nansum(AllLineScansWeighted,2);

AllLineScansMinusAvgSquared = (AllLineScans - repmat(AveragedLineScan.i, 1, size(AllLineScans, 2))).^2;

AllLineScansMinusAvgWeighted = AllLineScansMinusAvgSquared .* repmat(AllWeights, size(AllLineScansMinusAvgSquared, 1), 1); 

AveragedLineScan.std = sqrt(nansum(AllLineScansMinusAvgWeighted,2)/((sum(AllWeights>0)-1)/sum(AllWeights>0)));

     

end

