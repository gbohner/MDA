function [ out ] = radtodeg( in )
%RADTODEG Summary of this function goes here
%   Detailed explanation goes here

intype = whos('in');
out = in/pi*180.0;

if strcmp(intype.class,'single') 
   out = single(out);
end

end

