function LoadTracksToAlign( varargin )
%LOADTRACKSTOALIGN Summary of this function goes here
%   Detailed explanation goes here

global Config

if nargin > 0    
    DirRoot = varargin{1};
    DirSave = varargin{2};
    savename = [varargin{3} '_allData_controls.mat'];
elseif nargin == 0
    DirRoot = Config.analysis.choosetracks.DirSave;
    DirSave = Config.analysis.choosetracks.DirSave;
    savename = [Config.analysis.choosetracks.savename '_allData_controls.mat'];
end

folders = regexp(genpath(DirRoot),';','split');

data = struct('Time', {[]}, 'Position', {[]}, 'Intensities', {[]}, 'Config', {[]});

count = 0;

workbar(0/(numel(folders)-1),'Loading tracks...','Progress');

for n = 1:numel(folders)-1
   
   workbar(n/(numel(folders)-1),'Loading tracks...','Progress');
    
   s = what(folders{n});
   if numel(s) == 0
         continue;
   end
   
   fildata = [];
   for i1 = 1:numel(s.mat)
     try
      if strcmp(s.mat{i1}(1:19),'trackedFilamentData')
         fildata = [fildata i1];
      end
     end
   end
   s.mat = s.mat(fildata);
   
   
    for m = 1:numel(s.mat)
      a = load([s.path '\' s.mat{m}]);
        
     count = count + 1;
     data.Time{count} = a.FilEndFunc(:,1);
     data.Position{count} = a.FilEndFunc(:,2);
     data.Intensities{count} = a.Intensities;
     try
      data.Cods{count} = a.Filament.Cods(:,2);
     catch
      data.Cods{count} = nan(size(a.FilEndFunc,1),2);
     end
     data.Config{count} = a.Config;
     data.Config{count}.trackFile = [s.path '\' s.mat{m}];
      
    end
    
end

try
  save([DirSave '\' savename], '-struct', 'data');
catch
  DirSave = uigetdir(DirSave, 'specify folder to save to');
  save([DirSave '\' savename], '-struct', 'data');
end

end



