function da = forwardprop(dn,n,a,param)
%TANSIG.FORWARDPROP

% Dept of ECE, UoA

alpha1 = 0.01;
%da=n.*(n > 0) + alpha1*(exp(n) - 1).*(n <= 0);
da =  bsxfun(@times,dn,1.*(n >= 0) + (alpha1).*(n < 0));
 %da = bsxfun(@times,dn,1-(a.*a));
end
