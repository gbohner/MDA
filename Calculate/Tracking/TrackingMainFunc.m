function varargout = TrackingMainFunc( str )
%BTNMAIN_CB Summary of this function goes here
%   Detailed explanation goes here

global Config Data Gui

switch str
   case 'Load'
     try
      [FileName,PathName,FilterIndex] = uigetfile([Config.workdir '\*.tif'],'Load TIF files','MultiSelect','on');
      if PathName == 0
        warndlg('No file was chosen, stopping function.');
        return;
      end
      Data.Input.General.FileName = FileName;
      Data.Input.General.PathName = PathName;
      Data.Input.General.FilterIndex = FilterIndex;
      ToLoad = {};
      if iscell(FileName)
         for r1 = 1:numel(FileName)
            ToLoad(r1) = strcat(PathName, FileName(r1));
         end
      else
         ToLoad{1} = strcat(PathName, FileName);
      end
      Data.TirfInput = TirfInput(ToLoad{:});
      
      OnLoad(FileName);
      
      mda_disp_mode('tracking');
      Data.Track.ToTrack = [];
      
     catch ME
       rethrow(ME);
       warndlg('Files not loaded. Try again!');
     end
   case 'Mark'
%       display('clicked on Mark')
      ManualData = Mark();
      Data.Track.ToTrack{end} = ManualData;
      
   case 'Track'
      
      if isfield(Data.Track, 'Batch')
        if ~isempty(Data.Track.Batch)
          for i1 = 1:length(Data.Track.Batch)
            Data.Input.General = Data.Track.Batch{i1}.General;
            FileName = Data.Input.General.FileName;
            PathName = Data.Input.General.PathName;
            ToLoad = {};
            if iscell(FileName)
               for r1 = 1:numel(FileName)
                  ToLoad(r1) = strcat(PathName, FileName(r1));
               end
            else
               ToLoad{1} = strcat(PathName, FileName);
            end
            Data.TirfInput = TirfInput(ToLoad{:});

            OnLoad(FileName);

            mda_disp_mode('tracking');

            Data.Track.ToTrack = Data.Track.Batch{i1}.ToTrack;
            Data.Track.ToTrack_marked = Data.Track.ToTrack;
            Track();
          end
        else
          Data.Track.ToTrack_marked = Data.Track.ToTrack;
          Track();
        end
      else
        Data.Track.ToTrack_marked = Data.Track.ToTrack;
        Track();
      end
      
      
   case 'Reset'
      Gui.handles.figure_callback('Reset');
end

end

