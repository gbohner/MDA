function [ p ] = linspace2d( p1, p2, n )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if (p2 == p1) | (n == 1)
   p = [p1(1) * ones(n,1), p1(2) *ones(n,1)];
   return
end

direction = double(p2 - p1);

p = ones(n,2);
for i1 = 0:n-1
  p(i1+1,:) = p1 + i1./double(n-1) .* direction;
end

end

