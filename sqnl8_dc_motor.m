%% Experiment with SQNL8 for the NN replacement of PID
load('data_ts_01.mat')
pidin = data_ts_01(:,1);
pidout = data_ts_01(:,2);
%Normalization of inputs and targets
xmin= min(pidin);
xmax= max(pidin);

ymin= min(pidout);
ymax= max(pidout);
[I N] = size(pidin');
[O N] = size(pidout');
twothird = round((2/3)*N); %for training data
pidin_train = pidin(1:twothird,:);
pidout_train = pidout(1:twothird,:);
pidin_test = pidin(twothird+1:end,:);
pidout_test = pidout(twothird+1:end,:);

pidin_norm =  mapminmax_forward_x(pidin_train,xmin,xmax);
pidout_norm = mapminmax_forward_y(pidout_train,ymin,ymax);
% pidin_norm =  pidin_train;
% pidout_norm = pidout_train;
X = tonndata(pidin_norm,false,false);
T = tonndata(pidout_norm,false,false);
% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
 trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.
mingrad = 1e-500;
delay = 2;
% Create a Nonlinear Autoregressive Network with External Input
inputDelays = 1:delay;
feedbackDelays = 1:delay;
hiddenLayerSize = 3;
net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize,'open',trainFcn);
net.initFcn='initlay';  %remove, just for testing initial weights
% net.input.processFcns = {}; %{'removeconstantrows');
net.output.processFcns = {};
net.divideFcn = '';
net.layers.transferFcn={'sqnl8';'purelin'};
net.trainParam.min_grad = mingrad;
% Prepare the Data for Training and Simulation
% The function PREPARETS prepares timeseries data for a particular network,
% shifting time by the minimum amount to fill input states and layer
% states. Using PREPARETS allows you to keep your original time series data
% unchanged, while easily customizing it for networks with differing
% numbers of delays, with open loop or closed loop feedback modes.
[x,xi,ai,t] = preparets(net,X,{},T);
net.divideFcn = '';
net.trainParam.epochs = 1000;

% Train the Network
[net,tr] = train(net,x,t,xi,ai);
% load('sqnl8_dc_motorNet.mat') %3 Hidden neurons
% Test the Network on seen data
y = net(x,xi,ai);
%a = mapminmax_reverse(cell2mat(y),ymin,ymax);
a = cell2mat(y);
e = gsubtract(t,y);
performance = perform(net,t,y)
figure; plot(pidout_norm); hold on; plot((a));
legend('Actual','Predicted')
title('Actual Vs Predicted Output for Training/Seen Data-Floating Point')


%Testing: Unseen data
pidin_test_norm =mapminmax_forward_x(pidin_test,xmin,xmax);
pidout_test_norm =mapminmax_forward_y(pidout_test,ymin,ymax);
% pidin_test_norm = pidin_test;
% pidout_test_norm = pidout_test;
Xtest = tonndata(pidin_test_norm,false,false);
Ttest = tonndata(pidout_test_norm ,false,false);
[x_test,xi_test,ai_test,t_test] = preparets(net,Xtest,{},Ttest);

ytest = net(x_test,xi_test,ai_test);
err_test = gsubtract(t_test,ytest);
performance_test = perform(net,t_test,ytest)
%ynew = mapminmax('reverse',ytest,tsn);
% ynew = mapminmax_reverse(cell2mat(ytest),ymin,ymax);
ynew = cell2mat(ytest);
figure; plot(ynew); hold on; plot(pidout_test_norm);
legend('Actual','Predicted')
title('Actual Vs Predicted Output for Test/UnSeen Data-Floating Point')


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
% %biases
% b1 = net.b{1,1};
% b2 = net.b{2};
% 
% lt = length(cell2mat(x));
% lv = length((a));
% 
% oh=sqnl8(w1*cell2mat(x)+w2*cell2mat(x) + b1*ones(1,lt));
% out =  w3*oh+b2*ones(1,lt);
% figure;plot(out);


x = -1:0.5:7.5;
% x = x*100;
 t = sin(x);
t = t*100;
 maxt = max(max(t));
plot(x,t);
hold on;
lt = size(x,2);

trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.

% Create a Fitting Network
hiddenLayerSize = 5;
net = fitnet(hiddenLayerSize,trainFcn);

net.layers.transferFcn={'sqnl8';'purelin'};
net.input.processFcns = {}; %{'removeconstantrows');
net.output.processFcns = {};
net.divideFcn = '';
net = configure(net,x,t);

% Train the Network
%[net,tr] = train(net,x,t);
load sinusFunction_V3; %@t= t*100

% Test the Network
y = net(x);
e = gsubtract(t,y);
performance = perform(net,t,y)

% rr = [abs(y-t)]/maxt/2;
% rr(find(rr <= 0.25)) = 0;
% rr(find(rr > 0.25)) = 1;

% disp(sprintf('Total errors:%d',round(sum(sum(rr)))));

w1 = net.IW(1,1);
w1 = cell2mat(w1);

w2 = net.LW(2,1);
w2 = cell2mat(w2);

b1 = net.b{1,1};
b2 = net.b{2};
oh=sqnl8(w1*x + b1 * ones(1,lt));
%oh=tansig(w1*x + b1 * ones(1,lt));
out = w2*oh + b2 * ones(1,lt);
plot(x,out,'ro');


RM = 18; % Multiplier width,
PM = 6;
 
F=fimath('SumMode', 'SpecifyPrecision','ProductMode', 'SpecifyPrecision','OverflowAction','Saturate','ProductWordLength',RM,'SumWordLength',RM,'ProductFractionLength',PM,'SumFractionLength',PM);
 
 
x = fi(x,1,RM,PM,F);
w1 = fi(w1,1,RM,PM,F);
b1 = fi(b1,1,RM,PM,F);
w2 = fi(w2,1,RM,PM,F);
b2 = fi(b2,1,RM,PM,F);
 
xx = w1*x + b1*ones(1,lt);
oh=fi(sqnl8(double(xx)),1,RM,PM,F);
 
out_i = w2*oh+b2*ones(1,lt);  
plot(x,out_i,'k+');
legend('Desired Output', 'Floating Point Output', 'Integer Output')

%% Count the errors
% rr = [abs(double(out_i)-t)]/maxt/2;
% rr(find(rr <= 0.25)) = 0;
% rr(find(rr > 0.25))  = 1;
% 
% disp(sprintf('Total errors:%d',round(sum(sum(rr)))));
