function a = sqnl(n,varargin)

if ischar(n)
  a = nnet7.transfer_fcn(mfilename,n,varargin{:});
  return
end

% Apply
a = sqnl.apply(n);

