function DirRoot = GetGFPdata( input_args )
%GETGFPDATA Summary of this function goes here
%   Detailed explanation goes here


global Config Data

%Get the chosen tracks
try
  mytracks = Config.analysis.choosetracks.tracks;
end

if exist('mytracks','var')
  Tracks = mytracks;
else
  DirThis = [fileparts( mfilename('fullpath') ) filesep];
  a = load([DirThis 'Tracks_to_do.mat']);
  Tracks = a.Tracks;
end

DirRoot = Tracks{1}.file;
perarray = strfind(DirRoot, '\');
DirRoot = DirRoot(1:perarray(end-2)-1);

workbar(0,'Processing movies','Process Movies');
%Load the movies and get all tracks from a single movie
for n1 =1:numel(Tracks)
%    workbar(n1/numel(Tracks),'Processing movies','Process Movies');
   a = load(Tracks{n1}.file);
   Data = a.Data;
   Filament = a.Filament;
   clear a;
   
   %load movies into Data
   FileName = Data.Input.General.FileName;
   PathName = Data.Input.General.PathName;
   oldworkdir = strfind(PathName,'\');
   oldworkdir = PathName(1:oldworkdir(end-1)-1);
   PathName = strrep(PathName, oldworkdir, Config.workdir);
   try
      ToLoad = {};
      if iscell(FileName)
         for r1 = 1:numel(FileName)
            ToLoad(r1) = strcat(PathName, FileName(r1));
         end
      else
         ToLoad{1} = strcat(PathName, FileName);
      end
      Data.TirfInput = TirfInput(ToLoad{:});
%       if numel(Data.TirfInput.Stack) ~= 2
%          error('Movies not loaded properly');
%       end
   catch ME
      warning(['Movies not loaded properly, CHECK PARENT DIRECTORY IS SET CORRECTLY. Skipping Track #' num2str(n1)]);
      continue
   end
        
   workbar(n1/numel(Tracks),'Processing movies','Processing tracks');
   
   ProcessTracks(Filament,Tracks{n1}.num, PathName);
   
end

end

