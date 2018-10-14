function d = da_dn(n,a,param)

% Copyright 2017 The MathWorks, Inc.
alpha1 = 1;

  d = 1.*(n>0) + alpha1.*((1 + n/2).*(-2.0 <= n & n <= 0) + (0) .*(n<-2.0));
  
