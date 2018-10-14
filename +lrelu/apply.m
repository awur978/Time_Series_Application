function a = apply(n,param)

% Copyright 2012 The MathWorks, Inc.

alpha1 = 0.01;
%a = max(n,alpha1*(exp(n)-1));

a=n.*(n >= 0) + (alpha1*(n).*(n < 0));