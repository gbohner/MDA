function set_default_settings()

global Config Data Gui

% Config.settings.threshold.ThreshParams init
try
  a = load('basic_settings.mat');
  Config.workdir = a.workdir;
  Data.Input.General.PixelSize = a.PixelSize;
  Data.Input.General.FPS = a.FPS;
  Data.Input.General.MtStackNum = a.MtStackNum;

catch
  Config.workdir = 'C:\MDA_default';
  Data.Input.General.PixelSize = 160;
  Data.Input.General.FPS = 2;
  Data.Input.General.MtStackNum = 1;
end


Gui.general.scale = 1; %GUI SIZE, Recommended {1, 4/3, 24/15, 24/18, 7/3}, default scale is 1200 x 730

Config.settings.lookahead = 4;
Config.settings.mt_end_model = 'e'; 
   % 'e' -Half-gaussian + gaussian wall,  
   % 's' -gauss_surv acc to Demchouk's Microtubule Tip Tracking and Tip Structures at the Nanometer Scale
   %        Using Digital Fluorescence Microscopy
   % 'u' - Wittmann paper's Exponentially Modified Gaussian (EMG)
   
Config.settings.Align.Twarp = []; % Initia

Config.settings.threshold.ThreshParams.Threshold = 1.2;

Config.settings.trackCatastrophes = 1;

set_filters();

Data.Track.ToTrack = {};

Gui.mode = 'tracking';


%DynamicMarked Settings
   Config.tracking.advanced.DynamicMarked.neigh = 2; %Neighborhood for averaging filter
   Config.tracking.advanced.DynamicMarked.avg_growth = 2; %in pixel
   Config.tracking.advanced.DynamicMarked.lng = 10; %min 5; hard cap for maximum MT growth in pixels
   Config.tracking.advanced.DynamicMarked.lng = max(Config.tracking.advanced.DynamicMarked.avg_growth + 3, Config.tracking.advanced.DynamicMarked.lng);
   Config.tracking.advanced.DynamicMarked.variate_num = 4; %sideway steps to counter drifting of MTs
   Config.tracking.advanced.DynamicMarked.variate_step = 0.75; % pixel, will be multiplied by variate_num
   Config.tracking.advanced.DynamicMarked.dseed_threshold = 20; % in pixel, end distance threshold from seed
   Config.tracking.advanced.DynamicMarked.dseed_threshold_vclose = 10; % in pixel, end distance threshold from seed 
   Config.tracking.advanced.DynamicMarked.thresh_cat_value = -2500;  %Intensity drop (AU) that means a catastrophe is happening
   
  
  Config.analysis.choosetracks.DirRoot = Config.workdir; % directory to mine for all tracked microtubules
  Config.analysis.choosetracks.DirSave = Config.workdir; % directory to save statistics of all tracked microtubules
  Config.analysis.choosetracks.savename = 'defaultsavename'; % save name preamble for file
  
  
  Config.analysis.getgfpdata.filename = 'trackedFilamentData'; % save name preamble for individual microtubule tracks 
  Config.analysis.getgfpdata.cropsize = [6400 6400]; %nm, cropped image size around the microtubule end
  Config.analysis.getgfpdata.croppixelsize = 25; %nm, cropped image pixel size around the microtubule end (interpolated for finer grid)
  Config.analysis.getgfpdata.getintensities.boxsize = [1000 400]; %[along cross] nm, average the intensity in the a box around the tracked microtubule end to get a single intensity value per frame  
  Config.analysis.getgfpdata.getintensities.boxbehind = 500; %nm lattice box's start behind end's, , average the intensity in the a box behind the tracked microtubule end to get a single lattice intensity value per frame
   
%Set analysis.averagegfp settings
  Config.analysis.averagegfp.DirRoot = Config.workdir; % directory to mine for all tracked microtubules
  Config.analysis.averagegfp.imname = 'AvgedIms\defaultfilename'; % directory and file preamble to save statistics and images of individual tracked microtubules during time averaging
  MtModels = ModelLibrary('MT_end'); 
  GfpModels = ModelLibrary('GFP_end');
  Config.analysis.averagegfp.models.mt = GetModelChar(MtModels{1}); % Fit model types for averaged images
  Config.analysis.averagegfp.models.gfp = GetModelChar(GfpModels{1}); % Fit model types for averaged images
  Config.analysis.averagegfp.choose_align = 0; % Whether to automatically align the channels (requires our specific setup with the grid image)
  Config.analysis.averagegfp.preselect = 0; % Select all tracks to be averaged for batch processing
  Config.analysis.averagegfp.saveavgims = 1; % Save averaged images 
  Config.analysis.averagegfp.savefitims = 0; % Save images of fits to averaged images
  Config.analysis.averagegfp.savevideos = 0; % Save videos of averaging
  Config.analysis.averagegfp.skipdarkgfp = 0.15; % Disregard too dark frames from the average (usually due to bleacing/misfitted MT end)
  Config.analysis.averagegfp.MT_cropsize = 2000; %nm, length along the microtubule for the model fit
  Config.analysis.averagegfp.GFP_cropsize = 4000; %nm, length along the microtubule for the model fit
  Config.analysis.averagegfp.NewAlignThresh = 0; %nm

  
  Config.analysis.flexalign.params.laplacesmoothing = 3000; % To prevent dividing by very low numbers on background-subtracted data
  
  % Advanced settings
  Config.analysis.advanced.interpmethod = 'cubic'; %accepted: 'cubic', 'linear', Interpolation type used everywhere during analysis
  Config.analysis.advanced.shownormalised = 1;
   
   function set_filters()
    %SET_FILTERS Initiates settings for image filtering
    % Possibilities:
    %   - Wiener filter (matlab's standard wiener2() function)
    %   - Wallis filter (Threshold.WallisFilter)
    %   - Lucy-Richardson deconvolution (matlab's deconvlucy)

    Config.settings.threshold.ThreshParams.Wiener.on = 1;
    Config.settings.threshold.ThreshParams.Wallis.on = 1;
    Config.settings.threshold.ThreshParams.Wallis.args = {10000, 10000, 20, 1, 25, 1};
    %Wallis parameters are: 
    %{wanted mean, wanted deviation, maximum amplification, neighbour influence (0-1), window size(pixel), gauss smoothing on/off} 

    Config.settings.threshold.ThreshParams.Deconv.on = 0;
    Config.settings.threshold.ThreshParams.Deconv.lucy = {3};
    Config.settings.threshold.ThreshParams.Deconv.fwhm = 500/Data.Input.General.PixelSize; % Estimated width of microtubules at half-maximum intensity


    end
end