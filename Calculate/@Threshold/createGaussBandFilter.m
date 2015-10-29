function [ gaussBandFilter ] = createGaussBandFilter(obj,w_t,w_s)
%CREATEGAUSSFILTER Summary of this function goes here
%   Detailed explanation goes here

score = zeros(2*size(obj.output)+1);
mid = ceil(size(score)/2);
mid = mid(2);

for i=1:size(score,2)
%    score(i,:) = -w_t*1/normpdf(i,mid,w_s);
   score(i,:) = abs(i-mid)<w_s;
end

gaussBandFilter = score;

end

