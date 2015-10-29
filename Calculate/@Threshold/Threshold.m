classdef Threshold < handle
    %TIRFINPUT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        input = [];
        output = [];
    end
    
    methods
        function obj = Threshold(image)
            % Creates a class out of an image, with thresholding methods.
            obj.input = image;
            obj.output = image;
        end % TirfInput Constructor
        
        function [image] = DoThreshold(obj, ThreshParams)
           if isfield(ThreshParams, 'Wiener')
              if ThreshParams.Wiener.on
                 obj.output = wiener2(obj.output);
              end
           end
           if isfield(ThreshParams, 'Wallis')
              if ThreshParams.Wallis.on
                  WallisFilter(obj, ThreshParams.Wallis.args{:})
              end
           end
           if isfield(ThreshParams, 'Deconv')
              if ThreshParams.Deconv.on
                  sigma = ThreshParams.Deconv.fwhm / 2.35;
                  PSF = fspecial( 'gaussian', ceil(4*ThreshParams.Deconv.fwhm ), sigma );
                  obj.output = edgetaper( obj.output, PSF );
                  obj.output = deconvlucy( obj.output, PSF, ThreshParams.Deconv.lucy{:} );
              end
           end
%            if isfield(ThreshParams, 'Threshold')
% %               obj.output = im2bw(obj.output,ThreshParams.Threshold);
%            end
%            if isfield(ThreshParams, 'Morph')
%               if ThreshParams.Morph.on
%                  
%               end              
%            end
           
           image = obj.output;
        end
              
               
        
        WallisFilter(obj, Md, Dd, Amax, p, W, varargin )    
        
        [binaryImage] = DynamicMarked(obj);
        
        [gaussBandFilter] = createGaussBandFilter(obj,w_t,w_s);
        
        function reset(obj)
           obj.output = obj.input;
        end
        
    end
    
end


