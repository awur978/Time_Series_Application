function y =mapminmax_forward_x(x,xmin,xmax)
    ymax = 50;ymin=-50;
    %xmin=-12.4609;xmax=7.0414;
    y = (ymax-ymin)*(x-xmin)/(xmax-xmin) + ymin;
end
