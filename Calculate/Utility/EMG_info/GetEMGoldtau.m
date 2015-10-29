function out = GetEMGoldtau( tau, w, pixelsize )
%GETEMGVALS Summary of this function goes here
%   Detailed explanation goes here

  x = -200:0.02:200;
  x = x*pixelsize;
  
  %Compute values of the model
  f = exp(0.5.*w.^2./tau.^2 - (x-0)./tau).*...
        erfc(1./sqrt(2).*( w./tau - (x-0)./w));
    
  f = f/max(f);
    
%   figure;
%   plot(x,f,'b')
  
  [~, indm] = max(f); %find maximum position of the convolved signal
  
  expstart = x(indm) + w^2/(tau*2); %find theoretical start position of the convolved exp decrease
  
  m = f(abs(x - expstart) == min(abs(x - expstart))); % find intensity at start of exponential
  
  hm = m/2; %Get half maximum
  
  indhm = find(abs(f(x>expstart)-hm) == min(abs(f(x>expstart)-hm))); %Find position of half maximum
  indhm = indhm + sum(x<=expstart);
  
  hold on;
%   scatter(expstart, m,'g');
%   scatter(x(indhm), f(indhm),'r');
  
   
  
  out = abs(expstart - x(indhm));


end

