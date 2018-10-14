function da = forwardprop(dn,n,a,param)
%ELLIOTSIG.FORWARDPROP Forward propagate derivatives from input to output.

% Copyright 2012-2015 The MathWorks, Inc.

  da = 1 ./ ((1+abs(n)).^2);
  %da = bsxfun(@times,dn,d);
end
