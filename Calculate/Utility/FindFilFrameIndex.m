function ind = FindFilFrameIndex( Filament, frame )
%FINDFILFRAMEINDEX Summary of this function goes here
%   Detailed explanation goes here

  try
    A = Filament.Results(:,1);
    ind = find( abs(A - frame) == min(abs(A - frame)),1,'first');
  catch
    ind = 1;
  end
  
end

