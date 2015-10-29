function plotValues = GetFilEndFunc( Filament, varargin )
%GETFILENDFUNC Summary of this function goes here
%   Detailed explanation goes here

FilParams = checkParams(varargin);

%If bad (single frame) track return NaNs
if size(Filament.Results,1) <= 2
  plotValues = [NaN NaN];
  return;
end

time = Filament.Results(:,2);
frames = Filament.Results(:,1);
  
FilEnd = Filament.PosEnd;
origo = Filament.PosStart(1,:);

plotValues = NaN(numel(frames),2);

plotValues(:,1) = time;

plotValues(:,2) = sqrt(sum((FilEnd - repmat(origo,numel(time),1)).^2, 2));
%TODO: somehow store more data from tracking (like fit data for each middle point as well) 
% and use spline interpolation for much more precise mt length calculations.

if FilParams.DoPlot
  figure;
  plot(plotValues(:, 1), plotValues(:, 2));
end



  function p = checkParams(p)
    if ~isfield(p,'DoPlot')
      p.DoPlot = 0;
    end
  end


  function d = point_to_line(pt, v1, v2)
    a = v1 - v2;
    b = pt - v2;
    a=[a, 0];
    b=[b, 0];
    d = norm(cross(a,b)) / norm(a);
  end

end

