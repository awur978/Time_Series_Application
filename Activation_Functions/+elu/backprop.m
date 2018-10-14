function dn = backprop(da,n,a,param)
%TANSIG.BACKPROP
alpha1 = 1.0;
% Copyright 2012 The MathWorks, Inc.
 %dn =  1.*(n > 0) + (alpha1+a).*(n <= 0);
 dn = bsxfun(@times,da, 1.*(n > 0) + (alpha1+a).*(n <= 0));
 
% dn = bsxfun(@times,da,1-(a.*a));
end