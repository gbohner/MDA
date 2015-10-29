function [Filament] = afterfeatureconnect_as_func ()

global Config Data Gui

Objects = Data.Track.Objects;
FilTrack = Data.Track.FilTrack;

results_dir = [Data.Input.General.PathName '\Results\'];
   if ~isdir(results_dir)
      mkdir(results_dir);
   end
DirCurrent = results_dir;

sName = 'Filament_Data';
Filament=[];
Filament=fDefStructure(Filament,'Filament');

% if ~isempty(Stack)
%    sStack=size(Stack{1});
% end
nFilTrack=length(FilTrack);
for n = nFilTrack:-1:1
   nData=size(FilTrack{n},1);
   Filament(n).Name = ['Filament ' num2str(n)];
   Filament(n).File = Data.Input.General.FileName(Data.Input.General.MtStackNum);
   Filament(n).Directory = results_dir(1:end-8);
   Filament(n).PixelSize = Data.Input.General.PixelSize;
   
   marked_orientation = Data.Track.ToTrack_marked{n}.ori;
   
   for j=1:nData
      f = FilTrack{n}(j,1);
      m = FilTrack{n}(j,2);
      while isempty(Objects{f}) && f>1
         Objects{f} = Objects{f-1};
         f = f-1;
      end
      if f == 1
         while isempty(Objects{f}) && f<length(Objects)
            Objects{f} = Objects{f+1};
         end
      end
      Filament(n).Results(j,1) = single(f);
      Filament(n).Results(j,2) = single(f)/Data.Input.General.FPS;
      Filament(n).Results(j,3) = Objects{f}.center_x(m);
      Filament(n).Results(j,4) = Objects{f}.center_y(m);
      Filament(n).Results(j,6) = Objects{f}.length(1,m);
      Filament(n).Results(j,7) = Objects{f}.height(1,m);
      Filament(n).Results(j,8) = single(mod(Objects{f}.orientation(1,m),2*pi));
      Filament(n).Data{j} = Objects{f}.data{m};
      %TODO if it works, add the fit results of the end points to Filament.EndFitData
      
      current_orientation = Filament(n).Data{j}{1}(end,1:2) - Filament(n).Data{j}{1}(1,1:2);
      current_orientation = current_orientation/norm(current_orientation);
      if sum(abs(marked_orientation - current_orientation)) ...
            > sum(abs(marked_orientation - (-current_orientation)))
         Filament(n).Data{j}{1} = flipud(Filament(n).Data{j}{1});
         Filament(n).Data{j}{2}.p = fliplr(Filament(n).Data{j}{2}.p);
         Filament(n).Results(j,8) = single(mod(Filament(n).Results(j,8)+pi,2*pi));
      end

      Filament(n).PosStart(j,1:2)=Filament(n).Data{j}{1}(1,1:2);
      Filament(n).PosCenter(j,1:2)=Filament(n).Results(j,3:4)*Data.Input.General.PixelSize;
      Filament(n).PosEnd(j,1:2)=Filament(n).Data{j}{1}(end,1:2);
      Filament(n).Cods(j,1:2) = Objects{f}.cods(1:2,m);
      %(Config.RefPoint,'center')
      Filament(n).Results(:,3:4) = Filament(n).PosCenter;
      Filament(n).Results(:,5) = fDis( Filament(n).Results(:,3:4) );
   end
end

   fData=[DirCurrent sName '(' datestr(now,30) ').mat'];
   save(fData,'-v6','Filament','Objects');
   d.Config = Config;
   d.Data = rmfield(Data,'TirfInput');
   save(fData,'-struct','d','Data','Config','-append')
end