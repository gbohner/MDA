function [ maxval, maxpos ] = GetEMGmax( A, tau, w, pixelsize)
%GETEMGMAX Summary of this function goes here
%   Detailed explanation goes here

  x = -200:0.1:200;
  x = x * pixelsize;

  f = A./(2.*tau).*exp(0.5.*w.^2./tau.^2 - (x-0)./tau).*...
        erfc(1./sqrt(2).*( w./tau - (x-0)./w));
      
  f = fliplr(f);
      
  [maxval, maxpos] = max(f);
  maxpos = maxpos - (length(x)+1)/2;
  maxpos = maxpos * pixelsize;
  
end

