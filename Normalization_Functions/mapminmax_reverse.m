function[x]=mapminmax_reverse(y,xmin,xmax)
   % ymax = 1;ymin=-1;xmin=-12.4609;xmax=7.0414;
   ymax = 1;ymin=-1;
   %xmin= -5.6694e+03;xmax= 1.2107e+03;
    x=(((y*(xmax-xmin)) -( ymin*(xmax-xmin)))/(ymax-ymin))+xmin;
end