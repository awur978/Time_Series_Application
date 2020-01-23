function dn = backprop(da,n,a,param)
alpha1 = 1.0;

 dn = bsxfun(@times,da, 1.*(n > 0) + (alpha1+a).*(n <= 0));

end
