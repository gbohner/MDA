function exporttoexcel_linescans( AvgedImages, filename )
%EXPORTTOEXCEL_LINESCANS Summary of this function goes here
%   Detailed explanation goes here
excel_columns = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

LineScans = {'MT_axial','MT_lateral','GFP_axial','GFP_lateral'};

data = cell(1,length(LineScans));
for i1 = 1:size(AvgedImages,2)
  for j1 = 1:length(LineScans)   
    AvgIm = AvgedImages{1,i1};
    
    if isempty(AvgIm)
      continue;
    end
    
%     try
        switch j1
            case 1
                xorig = [AvgIm.mt.linescan.orig.axial.d, AvgIm.mt.linescan.orig.axial.i];
                xfit = [AvgIm.mt.linescan.fit.axial.d, AvgIm.mt.linescan.fit.axial.i];                
            case 2
                xorig = [AvgIm.mt.linescan.orig.lateral.d, AvgIm.mt.linescan.orig.lateral.i];
                xfit = [AvgIm.mt.linescan.fit.lateral.d, AvgIm.mt.linescan.fit.lateral.i];  
            case 3
                xorig = [AvgIm.gfp.linescan.orig.axial.d, AvgIm.gfp.linescan.orig.axial.i];
                xfit = [AvgIm.gfp.linescan.fit.axial.d, AvgIm.gfp.linescan.fit.axial.i];  
            case 4
                xorig = [AvgIm.gfp.linescan.orig.lateral.d, AvgIm.gfp.linescan.orig.lateral.i];
                xfit = [AvgIm.gfp.linescan.fit.lateral.d, AvgIm.gfp.linescan.fit.lateral.i];        
        end
        
        xorig = [i1 i1; NaN NaN; xorig];
        xfit = [i1 i1; NaN NaN; xfit];
        
        xorig = padarray(xorig, 1000 - length(xorig), NaN, 'post');
        xfit = padarray(xfit, 1000 - length(xfit), NaN, 'post');
       
        data{j1}(:,end+1:end+4) = [xorig xfit];
        
%     catch
%     end
    
  end

end

for j1 = 1:length(LineScans)
  for i1 = 1 : ceil(size(data{j1},2) / 252)
    xlswrite(filename,...
    data{j1}(:, (i1-1)*252+1 : min(i1*252, end)),...
    [LineScans{j1} '_' num2str(i1)]);
  end
end

%Add weighted normalized averaged LineScans
AvgLineScan_mt_axial = AverageLineScans(AvgedImages,'mt_axial', 1, 1);
AvgLineScan_mt_lateral = AverageLineScans(AvgedImages,'mt_lateral', 1, 1);
AvgLineScan_gfp_axial = AverageLineScans(AvgedImages,'gfp_axial', 1, 1);
AvgLineScan_gfp_lateral = AverageLineScans(AvgedImages,'gfp_lateral', 1, 1);

names = {'Position', 'Num', 'MT axial Int', 'MT axial Std', 'MT lateral Int', 'MT lateral Std', 'GFP axial Int', 'GFP axial Std', 'GFP lateral Int', 'GFP lateral std'};
AvgData = [AvgLineScan_mt_axial.d, AvgLineScan_mt_axial.nums, AvgLineScan_mt_axial.i, AvgLineScan_mt_axial.std, AvgLineScan_mt_lateral.i,AvgLineScan_mt_lateral.std,...
  AvgLineScan_gfp_axial.i, AvgLineScan_gfp_axial.std, AvgLineScan_gfp_lateral.i, AvgLineScan_gfp_lateral.std];

xlswrite(filename,names, 'Averaged LineScans normalized' );
xlswrite(filename, AvgData, 'Averaged LineScans normalized', ['A2:' excel_columns(size(AvgData,2)) num2str(size(AvgData,1)+1)]);


%Add weighted UNnormalized averaged LineScans
AvgLineScan_mt_axial = AverageLineScans(AvgedImages,'mt_axial', 0, 1);
AvgLineScan_mt_lateral = AverageLineScans(AvgedImages,'mt_lateral', 0, 1);
AvgLineScan_gfp_axial = AverageLineScans(AvgedImages,'gfp_axial', 0, 1);
AvgLineScan_gfp_lateral = AverageLineScans(AvgedImages,'gfp_lateral', 0, 1);

names = {'Position', 'Num', 'MT axial Int', 'MT axial Std', 'MT lateral Int', 'MT lateral Std', 'GFP axial Int', 'GFP axial Std', 'GFP lateral Int', 'GFP lateral std'};
AvgData = [AvgLineScan_mt_axial.d, AvgLineScan_mt_axial.nums, AvgLineScan_mt_axial.i, AvgLineScan_mt_axial.std, AvgLineScan_mt_lateral.i,AvgLineScan_mt_lateral.std,...
  AvgLineScan_gfp_axial.i, AvgLineScan_gfp_axial.std, AvgLineScan_gfp_lateral.i, AvgLineScan_gfp_lateral.std];

xlswrite(filename,names, 'Averaged LineScans original' );
xlswrite(filename, AvgData, 'Averaged LineScans original', ['A2:' excel_columns(size(AvgData,2)) num2str(size(AvgData,1)+1)]);
    
end

