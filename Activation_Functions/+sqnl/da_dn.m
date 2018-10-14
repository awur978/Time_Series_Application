function d = da_dn(n,a,param)

% Copyright 2012 The MathWorks, Inc.

d=zeros(size(n));

idx = find(n > 2);
n(idx) = 2;

idx = find(n < -2);
n(idx) = -2;

idx = find(n >= 0);
d(idx) = 1 - n(idx)/2;

idx = find(n < 0);
d(idx) = 1 + n(idx)/2;
