function [ output_args ] = mda_disp( varargin )
%DISP Summary of this function goes here
%   Detailed explanation goes here

global Config Gui Data

% %Display stuff to:
% Gui.handles.left.axes
% Gui.handles.right.axes

%Determine gui mode and call appropriate displaying functions
try
  success = 0;
  switch Gui.mode
    case 'tracking'
      %TODO
    case 'choosetracks'
      mda_disp_averagegfp(varargin{:});
    case 'averagegfp'
      mda_disp_averagegfp(varargin{:});
    case 'flexalign'
      mda_disp_flexalign(varargin{:});
  end
catch ME
  if success ~= 1
    %TODO handle errors
  end
end

%Functions for handling display in different modes
  function ret = mda_disp_tracking()
    %TODO currently works as it is, can be done later
  end

  function ret = mda_disp_averagegfp(varargin)
    %TODO
    %Left axis
    
      side = varargin{1};
      switch side
        case 'left'
          axes(Gui.handles.left.axes);
          cla(Gui.handles.left.axes, 'reset');
          xdata = varargin{2};
          ydata = varargin{3};
          if numel(varargin) > 3
            format = varargin{4:end};
          else
            format = {};
          end
          if numel(varargin) ~= 5
            plot(xdata,ydata,format{:});
          else
            ax = plotyy(xdata,ydata,varargin{4},varargin{5});
            set(ax(2),'YLim',[0 1]);
          end          
          
        case 'right'
          axes(Gui.handles.right.axes);
          cla(Gui.handles.right.axes, 'reset');
          axis xy;
          axis auto;
          type = varargin{2}; 
            %Types: 'Average MT', 'Average GFP', 'MT axial linescan', 'MT lateral linescan', 
            %       'GFP axial linescan', 'GFP lateral linescan',
            %       'MT-GFP axial linescan', 'MT-GFP lateral linescan'
          val = get(Gui.handles.right.popup,'Value');
          disptype = get(Gui.handles.right.popup,'String');
          disptype = disptype{val};
          
          if strcmp(disptype, type) || strcmp(disptype,'Auto')
            if sum(strcmp(type,{'Average MT', 'Average GFP','Average Chn 3'})) > 0
              %display an image
              axis ij;
              axis auto;
              imagesc(varargin{3:end});
              axis tight;
            else
              %display lineplots
              plot(varargin{3:end});
            end
          else
             %Do not change currently displayed thing
          end
      end
                
          
  end

  function ret = mda_disp_flexalign(varargin)
    %TODO
    %Left axis
    
      side = varargin{1};
      switch side
        case 'left'
          axes(Gui.handles.left.axes);
          cla(Gui.handles.left.axes, 'reset');
          xdata = varargin{2};
          ydata = varargin{3};
          if numel(varargin) > 3
            format = varargin{4:end};
          else
            format = {};
          end
          if numel(varargin) ~= 5
            plot(xdata,ydata,format{:});
          else
            ax = plotyy(xdata,ydata,varargin{4},varargin{5});
            set(ax(2),'YLim',[0 1]);
          end       
          
        case 'right'
          axes(Gui.handles.right.axes);
          cla(Gui.handles.right.axes, 'reset');
          type = varargin{2};
          
          if strcmp(type,'plot')
            plot(varargin{3:end});
          else
            plotyy(varargin{3:end});
          end
      end
  end
end

