function a = apply(n,param)

% Copyright 2017 The MathWorks, Inc.

alpha1 = 1;
a = n.*(n>0) + alpha1.*((n + n.^2/4).*(-2.0 <= n & n <= 0) + (-1) .*(n<-2.0));
