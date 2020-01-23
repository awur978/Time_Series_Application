function a = apply(n,param)

alpha1 = 1;

a=n.*(n > 0) + (alpha1*(exp(n) - 1).*(n <= 0));
