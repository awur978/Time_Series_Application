function a = apply(n,param)
%TANSIG.APPLY Apply transfer function to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  a = 2 ./ (1 + exp(-2*n)) - 1;
end


  