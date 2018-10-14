function da = forwardprop(dn,n,a,param)
%SQLU.FORWARDPROP

% Dept of ECE, UoA (dn,n,a,param)

alpha1 = 1;
d =  1.*(n>0) + alpha1.*((1 + n/2).*(-2.0 <= n & n <= 0) + (0) .*(n<-2.0));
da = bsxfun(@times,dn,d);
end
