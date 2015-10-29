function out = GetEMGfronthalfmax( tau, w, pixelsize )
%GETEMGFRONTHALFMAX Summary of this function goes here
%   Detailed explanation goes here


  x = -200:0.02:200;
  x = x*pixelsize;
  
  %Compute values of the model
  f = exp(0.5.*w.^2./tau.^2 - (x-0)./tau).*...
        erfc(1./sqrt(2).*( w./tau - (x-0)./w));
    
  f = f/max(f);
    
%   figure;
%   plot(x,f)
  
  [m, indm] = max(f); %find maximum of the convolved signal
  
  hm = m/2;
  
  indhm = find(abs(f(x<=0)-hm) == min(abs(f(x<=0)-hm))); %Find position of front half maximum
  
%   hold on;
%   scatter(x(indhm), f(indhm),'r');
  
    
  out = x(indhm);

end

