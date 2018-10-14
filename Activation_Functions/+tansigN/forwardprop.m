function da = forwardprop(dn,n,a,param)
%TANSIG.FORWARDPROP Forward propagate derivatives from input to output.

% Copyright 2012-2015 The MathWorks, Inc.

  da = 1-(a.*a);
  %da = bsxfun(@times,dn,1-(a.*a));
end
