% % b1 = net.b{1,1};
% % b2 = net.b{2}; 
% % h(t) = b1 + net.IW*[ x(:,t-1) ; x(:,t-2)]; % t = 3,4,...
% % y(t) = b2 + net.LW*h(t);
% %Input layer
% w1 = net.IW(1,1);
% w1 = cell2mat(w1);
% 
% 
% w2 = net.IW(1,2);
% w2 = cell2mat(w2);
% 
% %hidden layer
% w3 = net.LW(2,1);
% w3 = cell2mat(w3);
% 
% 
% b1 = net.b{1,1};
% b2 = net.b{2};

%% Play back
w1 = net.IW{1,1}; %input layer for pattern
w2 = net.IW{1,2}; %input layer for output feedback
b1 = net.b{1,1};  %input bias
b2 = net.b{2,1};  %hidden bias
w3 = net.LW{2,1}; %hidden layer

%convert input and outputs to double for multiplication
num_pat = length(cell2mat(x));
p1 = cell2mat(x);
p = p1(1,:);
y1 = cell2mat(t);
y2 = repmat(y1, 2, 1);
num_pat = size(p1,2);
 x1 = cell2mat(x_test(1,:)); % Convert each input to matrix
 x2 = cell2mat(x_test(2,:));
tapdelay1 =repmat(x1, 2, 1);
tapdelay2 = repmat(x2, 2, 1);
a1 = sqnl8(b1 + w1*tapdelay1 + w2*tapdelay2);
    
% Layer 2
a2 = b2 + w3*a1;
hidden = sqnl8(w1*p1 + w2*y2 + b1*ones(1, num_pat));
%hidden = tansig(w1(:,1)*p + w2(:,1)*y1 + b1*ones(1, num_pat));
out = w3*hidden + b2*ones(1, num_pat);


lt = length(cell2mat(x));
lv = length((a));


%     x1 = cell2mat(x_test(1,:)); % Convert each input to matrix
%     x2 = cell2mat(x_test(2,:));
%     xi1 = cell2mat(xi_test(1,:)); % Convert each input state to matrix
%     xi2 = cell2mat(xi_test(2,:));
%     [y3,xf1,xf2] = sqnl8_dc_mFunc(x1,x2,xi1,xi2);
%     accuracy3 = max(abs((ynew)-y3))

%     x1 = cell2mat(x(1,:)); % Convert each input to matrix
%     x2 = cell2mat(x(2,:));
%     xi1 = cell2mat(xi(1,:)); % Convert each input state to matrix
%     xi2 = cell2mat(xi(2,:));
%     [y3,xf1,xf2] = sqnl8_dc_mFunc(x1,x2,xi1,xi2);
%     accuracy3 = max(abs(cell2mat(y)-y3))



RM = 18; % Multiplier width,
PM = 6;
 
F=fimath('SumMode', 'SpecifyPrecision','ProductMode', 'SpecifyPrecision','OverflowAction','Saturate','ProductWordLength',RM,'SumWordLength',RM,'ProductFractionLength',PM,'SumFractionLength',PM);
pt = fi(cell2mat(x),1,RM,PM,F);
pv = fi(cell2mat(x_test),1,RM,PM,F);
w1 = fi(w1,1,RM,PM,F);
b1 = fi(b1,1,RM,PM,F);
w2 = fi(w2,1,RM,PM,F);
b2 = fi(b2,1,RM,PM,F);


xx =  w1*cell2mat(x)+w2*cell2mat(x) + b1*ones(1,lt);
oh=fi(sqnl8(double(xx)),1,RM,PM,F);
 
yy = w3*oh+b2*ones(1,lt);  
 
out_i = fi((double(yy)),1,RM,PM,F); 

figure;
plot(out_i,'b'); hold on; plot(cell2mat(t),'r')
% figure;
% subplot(211),plot(tt,out_i,'b.'); hold on; plot(tt,tt,'r.')
% title('Fixed Point Training')
% subplot(212),plot(tt,pt(1,:),'b.',tt,pt(2,:),'r.');


xxv = w1*pv + b1*ones(1,lv);
ohv=fi(sqnl8(double(xxv)),1,RM,PM,F);
ohv_integer = int16(double(ohv));
 
yyv = w2*ohv+b2*ones(1,lv);  
 
out_iv = fi(sqnl8(double(yyv)),1,RM,PM,F);
%out_iv = yyv;
figure;
plot(out_iv,'b'); hold on; plot(cell2mat(t_test),'r')
% figure;
% subplot(211),plot(tv,out_iv,'b.'); hold on; plot(tv,tv,'r.')
% title('Fixed Point testing')
% subplot(212),plot(tv,pv(1,:),'b.',tv,pv(2,:),'r.');

% figure;
% subplot(211),plot(tv,modelsim,'b.'); hold on; plot(tv,tv,'r.')
% subplot(212),plot(tt,pt(1,:),'b.',tt,pt(2,:),'r.');
% % 
% figure;
% subplot(211),plot(tv,modelsim,'b.'); hold on; plot(tv,out_iv,'r.')
% subplot(212),plot(tt,pt(1,:),'b.',tt,pt(2,:),'r.');