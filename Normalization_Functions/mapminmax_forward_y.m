function y =mapminmax_forward_y(x,xmin,xmax)
    ymax = 50;ymin=-50;
    %xmin= -5.6694e+03;xmax= 1.2107e+03;
    y = (ymax-ymin)*(x-xmin)/(xmax-xmin) + ymin;
end