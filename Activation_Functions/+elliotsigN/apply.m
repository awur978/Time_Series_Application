function a = apply(n,param)
%ELLIOTSIG.APPLY Apply transfer function to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  a = n ./ (1 + abs(n));
end


