function dn = backprop(da,n,a,param)
%SQLU.BACKPROP
alpha1 = 1.0;
% Copyright 2017 The MathWorks, Inc.
dn = bsxfun(@times,da, 1.*(n>0) + alpha1.*((1 + n/2).*(-2.0 <= n & n <= 0) + (0) .*(n<-2.0)));
end