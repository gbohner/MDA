function [ out ] = degtorad( in )
%DEGTORAD Summary of this function goes here
%   Detailed explanation goes here

intype = whos('in');
out = in/180.0*pi;

if strcmp(intype.class,'single') 
   out = single(out);
end

end

