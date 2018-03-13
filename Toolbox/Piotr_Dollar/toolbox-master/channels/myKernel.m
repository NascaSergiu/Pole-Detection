function img = myKernel( I )
%MYKERNEL Summary of this function goes here
%   Detailed explanation goes here

kernel = [-1 0 1];

img = imfilter(I, kernel);

end

