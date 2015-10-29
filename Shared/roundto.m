function [ out] = roundto( num, to )
%ROUNDTO Summary of this function goes here
%   Detailed explanation goes here

intype = whos('num');

out = round(double(num)*(1.0/to))*double(to);

if strcmp(intype.class,'single') 
   out = single(out);
end

end

