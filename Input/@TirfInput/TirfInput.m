classdef TirfInput < handle
    %TIRFINPUT Class that contains loaded data and additional information about it.
    %   Properies: Stack, Info
    %   Functions: play(num) - plays stack #num as video
    %              pop(num, frame) - return frame #frame from stack #num
    %              pop(num, frame, rect) - return part rect(x0,y0 : x1,y1) from #frame
    
    properties
        Stack = {};
        Info = {};
    end
    
    methods
        function obj = TirfInput(varargin)
            % Read the specified TIRF stacks into the different layers of
            % Stack.
            for i1 = 1:nargin
                % obj.Stack{i1} = fStackRead(varargin{i1});
                fname = varargin{i1};
                obj.Info{i1} = imfinfo(fname);
                num_images = numel(obj.Info{i1});
                workbar(0,['Reading Stack #' num2str(i1) '...'],'Progress');
                for i2 = 1:num_images
                    obj.Stack{i1}{i2} = imread(fname, i2);
                    workbar(i2/num_images,['Reading Stack #' num2str(i1) '...'],'Progress');
                end
            end
        end % TirfInput Constructor
        
        function play(obj, num)
            implay(reshape([obj.Stack{num}{:}],512,512,[]))
        end
        
        function [image] = pop(obj, num, frame, varargin)
           if nargin<=3
              try
                 image = obj.Stack{num}{frame};
              catch Exc
                 display(Exc);
                 image = zeros(512);
              end
           else
              rect = varargin{1};
              image = obj.Stack{num}{frame}...
                  (max(rect(2),1):min(rect(2)+rect(4)-1,end), max(rect(1),1):min(rect(1)+rect(3)-1,end));
           end
        end
        
        
    end
    
end

