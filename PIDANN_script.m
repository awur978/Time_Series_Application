% load('pid_output.mat')
% load('PID_input.mat')

% load('data_ts_001.mat')
% pidin = data_ts_001(:,1);
% pidout = data_ts_001(:,2);

load('data_ts_01.mat')
pidin = data_ts_01(:,1);
pidout = data_ts_01(:,2);

% load('data_ts_1.mat')
% pidin = data_ts_1(:,1);
% pidout = data_ts_1(:,2);

% load('data_ts_2.mat')
% pidin = data_ts_2(:,1);
% pidout = data_ts_2(:,2);

% load('experiment_1_PID_Output.mat')
% load('experiment_1_PID_Input.mat')
% pidin = inp;
% pidout = output;
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
% a=1;
% b=-1;
% pidin_norm = a+(b-a)*(pidin_train-min(pidin_train))/( max(pidin_train)-min(pidin_train));
% pidout_norm = a+(b-a)*(pidout_train-min(pidout_train))/( max(pidout_train)-min(pidout_train));
%y = (ymax-ymin)*(x-xmin)/(xmax-xmin) + ymin;
% [pidin_norm, ps] =  mapminmax(pidin_train');
% [pidout_norm,tsn] = mapminmax(pidout_train');
% X = tonndata(pidin_norm',false,false);
% T = tonndata(pidout_norm',false,false);

pidin_norm =  mapminmax_forward_x(pidin_train,xmin,xmax);
pidout_norm = mapminmax_forward_y(pidout_train,ymin,ymax);
X = tonndata(pidin_norm,false,false);
T = tonndata(pidout_norm,false,false);
%Testing: Unseen data
% Xtest = tonndata(pidin_test,false,false);
% Ttest = tonndata(pidout_test,false,false);
% 
% Choose a Training Function
% For a list of all training functions type: help nntrain
% 'trainlm' is usually fastest.
% 'trainbr' takes longer but may be better for challenging problems.
% 'trainscg' uses less memory. Suitable in low memory situations.
 trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.
mingrad = 1e-500;
delay = 2;
% Create a Nonlinear Autoregressive Network with External Input
% inputDelays = 1:4;
% feedbackDelays = 1:4;
% hiddenLayerSize = 20;
inputDelays = 1:delay;
feedbackDelays = 1:delay;
hiddenLayerSize = 3;
net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize,'open',trainFcn);
net.initFcn='initlay';  %remove, just for testing initial weights
net.layers.transferFcn={'tansig';'purelin'};
net.trainParam.min_grad = mingrad;
% Prepare the Data for Training and Simulation
% The function PREPARETS prepares timeseries data for a particular network,
% shifting time by the minimum amount to fill input states and layer
% states. Using PREPARETS allows you to keep your original time series data
% unchanged, while easily customizing it for networks with differing
% numbers of delays, with open loop or closed loop feedback modes.
[x,xi,ai,t] = preparets(net,X,{},T);
% net.input.processFcns = {}; %{'removeconstantrows');
% net.output.processFcns = {};
net.divideFcn = '';
net.trainParam.epochs = 150;
% Setup Division of Data for Training, Validation, Testing
% net.divideParam.trainRatio = 70/100;pidout_norm = = (ymax-ymin)*(pidout-xmin)/(xmax-xmin) + ymin;;
% net.divideParam.valRatio = 15/100;
% net.divideParam.testRatio = 15/100;

% Train the Network
[net,tr] = train(net,x,t,xi,ai);

% Test the Network on seen data
y = net(x,xi,ai);
%a = mapminmax('reverse',y,tsn);
a = mapminmax_reverse(cell2mat(y),ymin,ymax);

e = gsubtract(t,y);
performance = perform(net,t,y)
figure; plot(pidout_train); hold on; plot((a));
legend('Actual','Predicted')
title('Actual Vs Predicted Output for Training/Seen Data (Un-normalized)')

%Testing: Unseen data
% pidin_test_norm =mapminmax('apply',pidin_test,ps);
% pidout_test_norm =mapminmax('apply',pidout_test,tsn);
pidin_test_norm =mapminmax_forward_x(pidin_test,xmin,xmax);
pidout_test_norm =mapminmax_forward_y(pidout_test,ymin,ymax);
Xtest = tonndata(pidin_test_norm,false,false);
Ttest = tonndata(pidout_test_norm ,false,false);
[x_test,xi_test,ai_test,t_test] = preparets(net,Xtest,{},Ttest);

ytest = net(x_test,xi_test,ai_test);
err_test = gsubtract(t_test,ytest);
performance_test = perform(net,t_test,ytest)
%ynew = mapminmax('reverse',ytest,tsn);
ynew = mapminmax_reverse(cell2mat(ytest),ymin,ymax);
figure; plot(ynew); hold on; plot(pidout_test);
legend('Actual','Predicted')
title('Actual Vs Predicted Output for Test/UnSeen Data (Un-normalized)')
% View the Network
%view(net)

% Plots
% Uncomment these lines to enable various plots.
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, ploterrhist(e)
%figure, plotregression(t,y)
%figure, plotresponse(t,y)
%figure, ploterrcorr(e)
%figure, plotinerrcorr(x,e)

% Closed Loop Network
% Use this network to do multi-step prediction.
% The function CLOSELOOP replaces the feedback input with a direct
% connection from the outout layer.
netc = closeloop(net);
netc.name = [net.name ' - Closed Loop'];
%view(netc)
[xc,xic,aic,tc] = preparets(netc,X,{},T);
yc = netc(xc,xic,aic);
closedLoopPerformance = perform(net,tc,yc)

% Step-Ahead Prediction Network
% For some applications it helps to get the prediction a timestep early.
% The original network returns predicted y(t+1) at the same time it is
% given y(t+1). For some applications such as decision making, it would
% help to have predicted y(t+1) once y(t) is available, but before the
% actual y(t+1) occurs. The network can be made to return its output a
% timestep early by removing one delay so that its minimal tap delay is now
% 0 instead of 1. The new network returns the same outputs as the original
% network, but outputs are shifted left one timestep.
nets = removedelay(net);
nets.name = [net.name ' - Predict One Step Ahead'];
% view(nets)
[xs,xis,ais,ts] = preparets(nets,X,{},T);
ys = nets(xs,xis,ais);
stepAheadPerformance = perform(nets,ts,ys)

% figure;plot(cell2mat(t)); hold on; plot(cell2mat(y));
% legend('Actual','Predicted','Location','NorthEastOutside')
% title('Actual Vs Predicted Output')
% figure;plot(cell2mat(e));
% title('Error')



%% Test on new data
% xtest_norm = mapminmax('apply',Xtest,ps);
% ttest_norm = mapminmax('apply',Ttest,ps);
% [xtest,xitest,aitest,ttest] = preparets(net,xtest_norm,{},ttest_norm);
% y = net(xtest,xitest,aitest);
% ynew = mapminmax('reverse',y,tsn);
% y = net(xtest,xitest,aitest);
% e = gsubtract(ttest,y);
% performance = perform(net,ttest,y)
% 
% figure;plot(cell2mat(ttest)); hold on; plot(cell2mat(y));
% legend('Actual','Predicted','Location','NorthEastOutside')
% title('Actual Vs Predicted Output')
% figure;plot(cell2mat(e));
% title('Error')
% 
%% Mapminmax function
% function[y]=mapminmax_forward(x)
%     ymax = 1;ymin=-1;xmin=-12.4609;xmax=7.0414;
%     y = (ymax-ymin)*(x-xmin)/(xmax-xmin) + ymin;
% end

% function[x]=mapminmax_reverse(y)
%     ymax = 1;ymin=-1;xmin=-12.4609;xmax=7.0414;
%    % y = (ymax-ymin)*(x-xmin)/(xmax-xmin) + ymin;
%     x=(((y*(xmax-xmin)) -( ymin*(xmax-xmin)))/(ymax-ymin))+xmin;
% end

% u.time=t;
% u.signals.values=y;


%% Random weight initialization
% net = patternet;
% 
% will default to H = 10 hidden nodes. For other values use
% 
% net = patternnet(H);
% 
% If
% 
% size(input) = [I N ]
% 
% size(target) = [O N ]
% 
% the node topology is I-H-O.
% 
% For a manual weight initialization, first configure the net:
% 
% net = configure(net,x,t);
% 
% For a random weight initialization, initialize the random number generator. Then generate and assign the weights:
% 
% rng(0)
% 
% IW = 0.01*randn(H,I);
% 
% b1 = 0.01*randn(H,1);
% 
% LW = 0.01*randn(O,H);
% 
% b2 = 0.01*randn(O,1);
% 
% then
% 
% net.IW{1,1} = IW;
% 
% net.b{1,1} = b1;
% 
% net.LW{2,1} = LW;
% 
% net.b{2,1} = b2;
