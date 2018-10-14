function dn = backprop(da,n,a,param)
%TANSIG.BACKPROP Backpropagate derivatives from outputs to inputs

% Copyright 2012-2015 The MathWorks, Inc.
   dn = 1-(a.*a);
  %dn = bsxfun(@times,da,1-(a.*a));
end
