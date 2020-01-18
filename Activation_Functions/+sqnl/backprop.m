function dn = backprop(da,n,a,param)


d=zeros(size(n));

idx = find(n > 2);
n(idx) = 2;

idx = find(n < -2);
n(idx) = -2;

idx = find(n >= 0);
d(idx) = 1 - n(idx)/2;

idx = find(n < 0);
d(idx) = 1 + n(idx)/2;
dn = bsxfun(@times,da,d);
