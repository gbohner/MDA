function nb = findnearest(v1,v2)
  %returns indices from v2 nearest to values of v1 in 1D vectors;
  [v2, oldinds] = sort(v2);
  nb = NaN(length(v1),1);
  for j1 = 1:length(v1)
    dist = Inf;
    for j2 = 1:length(v2)
      dist_new = abs(v1(j1) - v2(j2));
      if dist_new > dist            
          nb(j1) = j2-1;
          break
      end
      dist = dist_new;
      if j2 == length(v2)
        nb(j1) = j2;
      end
    end
  end
  
  nb = oldinds(nb);
end