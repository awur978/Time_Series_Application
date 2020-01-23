function d = da_dn(n,a,param)

alpha1 = 1;
d =  1.*(n > 0) + (alpha1+a).*(n <= 0);
end
