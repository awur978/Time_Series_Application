function d = da_dn(n,a,param)

% Copyright 2012 The MathWorks, Inc.
alpha1 = 1;

  %d = max(n>1,a+alpha1);

  d =  1.*(n > 0) + (alpha1+a).*(n <= 0);
  
  
  %dLdX = dLdZ .* ((X > 0) + ...
                %((layer.alpha + Z) .* (X <= 0))); 