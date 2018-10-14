function a = elliotsigN(n,varargin)
%ELLIOTSIG Elliot symmetric sigmoid transfer function.
%
% Transfer functions convert a neural network layer's net input into
% its net output.
%	
% A = <a href="matlab:doc elliotsig">elliotsig</a>(N) takes an SxQ matrix of S N-element net input column
% vectors and returns an SxQ matrix A of output vectors, where each element
% of N in is squashed from the interval [-inf inf] to the interval [-1 1]
% with an "S-shaped" function.
%
% The advantage of this transfer function over other sigmoids is that it is
% fast to calculate on simple computing hardware as it does not require any
% exponential or trigonometric functions.  Its disadvantage is that it only
% flattens out for large inputs, so its effect is not as local as the other
% sigmoid functions. This may result in more training iterations or require
% more neurons to achieve the same accuracy.
%
% Here a layer output is calculate from a single net input vector:
%
%   n = [0; 1; -0.5; 0.5];
%   a = <a href="matlab:doc elliotsig">elliotsig</a>(n);
%
% Here is a plot of this transfer function:
%
%   n = -5:0.01:5;
%   plot(n,<a href="matlab:doc elliotsig"> elliotsig</a>(n))
%   set(gca,'dataaspectratio',[1 1 1],'xgrid','on','ygrid','on')
%
% Here this transfer function is assigned to the ith layer of a network:
%
%   net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_transferFcn">transferFcn</a> = '<a href="matlab:doc elliotsig">elliotsig</a>';
%
%	See also TANSIG, LOGSIG.

% Copyright 2012 The MathWorks, Inc.

% NNET 7.0 Compatibility
% WARNING - This functionality may be removed in future versions
if ischar(n)
  a = nnet7.transfer_fcn(mfilename,n,varargin{:});
  return
end

% Apply
a = elliotsigN.apply(n);

