w1 = net.IW(1,1);
w1 = cell2mat(w1);

w2 = net.LW(2,1);
w2 = cell2mat(w2);

b1 = net.b{1,1};
b2 = net.b{2};
lt = length(x);
lv = length(x_test);

% Without fixed point
% xx = w1*x + b1*ones(1,lt);
% oh=(sqnl8(double(xx)));
%  
% yy = purelin(w2*oh+b2*ones(1,lt));  
%  
% 
% %out_i = yy;
% figure;
% plot(yy,'b'); hold on; plot(t,'r')
% title('Fixed Point Training')
% legend('Predicted','Actual')

%% 
RM = 18; % Multiplier width,
PM = 6;
 
F=fimath('SumMode', 'SpecifyPrecision','ProductMode', 'SpecifyPrecision','OverflowAction','Saturate','ProductWordLength',RM,'SumWordLength',RM,'ProductFractionLength',PM,'SumFractionLength',PM);
pt = fi(x,1,RM,PM,F);
pv = fi(x_test,1,RM,PM,F);
w1 = fi(w1,1,RM,PM,F);
b1 = fi(b1,1,RM,PM,F);
w2 = fi(w2,1,RM,PM,F);
b2 = fi(b2,1,RM,PM,F);

xx = w1*pt + b1*ones(1,lt);
oh=fi(sqnl8(double(xx)),1,RM,PM,F);
 
yy = w2*oh+b2*ones(1,lt);  
 
out_i = fi((double(yy)),1,RM,PM,F);
%out_i = fi(sqnl8(double(yy)),1,RM,PM,F);
%out_i = yy;
figure;
plot(out_i,'b'); hold on; plot(t,'r')
title('Fixed Point Training')
legend('Predicted','Actual')

xxv = w1*pv + b1*ones(1,lv);
ohv=fi(sqnl8(double(xxv)),1,RM,PM,F);
% ohv_integer = int16(double(ohv));
ohv_integer = (double(ohv));

 
yyv = w2*ohv+b2*ones(1,lv);  
 
out_iv = fi((double(yyv)),1,RM,PM,F);
%out_iv = fi(sqnl8(double(yyv)),1,RM,PM,F);
%out_iv = yyv;

figure;
plot(out_iv,'b'); hold on; plot(t_test,'r')
title('Fixed Point testing')
legend('Predicted','Actual')

figure;
plot(modelsim,'b'); hold on; plot(out_iv(:,1:30000),'r')
figure;
plot(modelsim,'b'); hold on; plot(t_test(:,1:30000),'r')

