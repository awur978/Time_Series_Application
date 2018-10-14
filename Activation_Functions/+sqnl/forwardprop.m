function da = forwardprop(dn,n,a,param)
%TANSIG.FORWARDPROP

% Dept of ECE, UoA

d=zeros(size(n));

idx = find(n > 2);
n(idx) = 2;

idx = find(n < -2);
n(idx) = -2;

idx = find(n >= 0);
d(idx) = 1 - n(idx)/2;

idx = find(n < 0);
d(idx) = 1 + n(idx)/2;

da = bsxfun(@times,dn,d);
