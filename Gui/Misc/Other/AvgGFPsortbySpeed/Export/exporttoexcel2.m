function data = exporttoexcel2( AvgedImages, filename )
%EXPORTTOEXCEL Summary of this function goes here
%   Detailed explanation goes here

data = cell(1,size(AvgedImages,1));
filepaths = cell(1,size(AvgedImages,1));
write_header = 1;
for i1 = 1:size(AvgedImages,2)
  for j1 = 1:size(AvgedImages,1)   
    x = [];
    AvgIm = AvgedImages{j1,i1};
    
    if isempty(AvgIm)
      continue;
    end
    
    if write_header && ~isempty(AvgIm)
      WriteNames(filename, j1);
      write_header = 0;
    end
    
    try
      %%% Filename
      shortfilepath = strfind(AvgIm.file,filesep);
      shortfilepath = AvgIm.file(shortfilepath(end-2)+1:end);
      filepaths{i1} = shortfilepath;
      %%% General stuff
      x(1) = i1;
      x(end+1) = AvgIm.frames(1);
      x(end+1) = AvgIm.frames(2);
      x(end+1) = AvgIm.FPS;
      x(end+1) = AvgIm.growthSpeed;
      x(end+1) = AvgIm.mt.cod;
      x(end+1) = AvgIm.gfp.cod;
      
      %%% GFP stuff
      x(end+1) = NaN; %excel leaves it empty
      x(end+1) = AvgIm.gfp.fit_result.psf;
      x(end+1) = AvgIm.gfp.fit_result.w;
      x(end+1) = AvgIm.gfp.fit_result.ori;
      if strcmp(AvgIm.gfp.model,'u')
        x(end+1) = AvgIm.gfp.fit_result.tau;
        x(end+1) = AvgIm.gfp.fit_result.tau / (AvgIm.growthSpeed*1000/60);
        x(end+1) = GetEMGmax(AvgIm.gfp.fit_result.h, AvgIm.gfp.fit_result.tau, AvgIm.gfp.fit_result.w, AvgIm.pixelsize);
      elseif strcmp(AvgIm.gfp.model,'v')
        x(end+1) = AvgIm.gfp.fit_result.tau;
        x(end+1) = AvgIm.gfp.fit_result.tau / (AvgIm.growthSpeed*1000/60);
        x(end+1) = AvgIm.gfp.fit_result.lat;
        x(end+1) = GetEMGmax(AvgIm.gfp.fit_result.h, AvgIm.gfp.fit_result.tau, AvgIm.gfp.fit_result.w, AvgIm.pixelsize);
      elseif strcmp(AvgIm.gfp.model,'c')
        x(end+1) = AvgIm.gfp.fit_result.tau;
        x(end+1) = AvgIm.gfp.fit_result.tau / (AvgIm.growthSpeed*1000/60);
        x(end+1) = AvgIm.gfp.fit_result.h;
      elseif strcmp(AvgIm.gfp.model,'a')
        x(end+1) = AvgIm.gfp.fit_results.lat;
        x(end+1) = AvgIm.gfp.fit_result.h;
      else
        x(end+1) = AvgIm.gfp.fit_result.h;
      end
      x(end+1) = AvgIm.Intensities.gfp.end.max;
      x(end+1) = AvgIm.Intensities.gfp.end.mean;
      x(end+1) = AvgIm.Intensities.gfp.norm;
      
      %%% MT stuff
      x(end+1) = NaN; %excel leaves it empty
      x(end+1) = AvgIm.mt.fit_result.psf;
      x(end+1) = AvgIm.mt.fit_result.w;
      x(end+1) = AvgIm.mt.fit_result.ori;
      if strcmp(AvgIm.mt.model,'u')
        x(end+1) = AvgIm.mt.fit_result.tau;
        x(end+1) = GetEMGmax(AvgIm.mt.fit_result.h, AvgIm.mt.fit_result.tau, AvgIm.mt.fit_result.w, AvgIm.pixelsize);
      else
        x(end+1) = AvgIm.mt.fit_result.h;
      end
      
      %%%
      x(end+1) = AvgIm.posdiff;
      if strcmp(AvgIm.mt.model,'u')
          x(end+1) = GetEMGfronthalfmax(AvgIm.mt.fit_result.tau, AvgIm.mt.fit_result.w, AvgIm.pixelsize);
          x(end+1) = x(end-1) + x(end);
      end
    catch
    end
    
    data{j1}(end+1,:) = x;
  end

end

for j1 = 1:1
  xlswrite(filename,filepaths', ['Results' num2str(j1)], ['A2:A' num2str(size(filepaths,2)+1)]);
  xlswrite(filename,data{j1}, ['Results' num2str(j1)], ['B2:' get_excel_column(size(data{j1},2)+1) num2str(size(data{j1},1)+1)]);
end

  function WriteNames(filename, sheet_num)
     %%% General stuff
      names{1} = 'File';
      names{end+1} = 'Num'; 
      names{end+1} = 'Frames (from)'; 
      names{end+1} = 'Frames (to)'; 
      names{end+1} = 'Frames per second';
      names{end+1} = 'Growth speed (um/min)'; 
      names{end+1} = 'MtCoD'; 
      names{end+1} = 'GfpCoD';

      %%% GFP stuff
      names{end+1} = 'GFP';
      names{end+1} = 'PSF sigma (nm)';
      names{end+1} = 'Front sigma (nm)';
      names{end+1} = 'Orientation (degrees)'; 
      if strcmp(AvgIm.gfp.model,'u')
        names{end+1} = 'Tau (nm)'; 
        names{end+1} = 'Decoration Time (s)';
        names{end+1} = 'Intensity (fit, au)';
      elseif strcmp(AvgIm.gfp.model,'v')
        names{end+1} = 'Tau (nm)'; 
        names{end+1} = 'Decoration Time (s)';
        names{end+1} = 'Lattice intensity (fit, au)';
        names{end+1} = 'Intensity (fit, au)';
      elseif strcmp(AvgIm.gfp.model,'c')
        names{end+1} = 'Tau (nm)'; 
        names{end+1} = 'Decoration Time (s)';
        names{end+1} = 'Intensity (fit, au)';
      elseif strcmp(AvgIm.gfp.model,'a')
        names{end+1} = 'Relative lattice height';
        names{end+1} = 'Intensity (fit, au)';
      else
        names{end+1} = 'Intensity (fit, au)';
      end
      names{end+1} = 'Intensity(end max, au)';
      names{end+1} = 'Intensity(end mean, au)';
      names{end+1} = 'Intensity(norm, au)';

      %%% MT stuff
      names{end+1} = 'MT';
      names{end+1} = 'PSF sigma (nm)';
      names{end+1} = 'Front sigma (nm)'; 
      names{end+1} = 'Orientation (degrees)';
      if strcmp(AvgIm.mt.model,'u')
        names{end+1} = 'Tau (nm)'; 
        names{end+1} = 'Intensity (fit, au)';
      else
        names{end+1} = 'Intensity (fit, au)';
      end

      %%% Both needed
      names{end+1} = 'Posdiff (nm)';
      if strcmp(AvgIm.mt.model,'u')
          names{end+1} = 'Correction (nm)';
          names{end+1} = 'Posdiff corrected (nm)';
      end
      
      try
        delete(filename);
      end
      xlswrite(filename, names, ['Results' num2str(sheet_num)]);
  end

% try
   exporttoexcel_linescans2(AvgedImages, filename);
% catch
%     warndlg('Linescans were not exported');
% end

  function str = get_excel_column(num)
    excel_columns = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    str = '';
    if num > 26
      str = excel_columns(floor((num - 1)/26));
      num = mod(num, 26);
      if num == 0
        num = 26;
      end
    end
    str = [str excel_columns(num)];
  end

end

