%Load training and testing data 
load('data_ts_01.mat')
pidin = data_ts_01(:,1);
pidout = data_ts_01(:,2);
[I N] = size(pidin');
[O N] = size(pidout');
twothird = round((2/3)*N); %for training data
pidin_train = pidin(1:twothird,:);
pidout_train = pidout(1:twothird,:);
pidin_test = pidin(twothird+1:end,:);
pidout_test = pidout(twothird+1:end,:);

xmin= min(pidin);
xmax= max(pidin);

ymin= min(pidout);
ymax= max(pidout);

load('sqnl8_train_output.mat')
load('sqnl8_train_input.mat')
x_unscale = new_inp;
t_unscale = new_oup;
x = mapminmax(x_unscale)*50.72;
t = mapminmax(t_unscale)*120.72;
load('sqnl8_test_output.mat')
load('sqnl8_test_input.mat')
x_test_unscale = new_inptest;
t_test_unscale = new_ouptest;
x_test = mapminmax(x_test_unscale)*50.72;
t_test = mapminmax(t_test_unscale)*120.72;

% %scale up the data for sqnl8
% x =  mapminmax_forward_x(x_unscale,xmin,xmax); %x_unscale;%
% t = mapminmax_forward_y(t_unscale,ymin,ymax);
% %t = t_unscale;
% x_test = mapminmax_forward_x(x_test_unscale,xmin,xmax); % x_test_unscale;%
% t_test = mapminmax_forward_y(t_test_unscale,ymin,ymax); %t_test_unscale;%

% x = (pidin_train*50.72)';
% t = (pidout_train)';
% x_test = (pidin_test*50.72)';
% t_test = (pidout_test)';

trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.

% Create a Fitting Network
hiddenLayerSize = 3;
net = fitnet(hiddenLayerSize,trainFcn);
net.layers.transferFcn={'sqnl8';'purelin'};
% % Setup Division of Data for Training, Validation, Testing
% net.divideParam.trainRatio = 70/100;
% net.divideParam.valRatio = 15/100;
% net.divideParam.testRatio = 15/100;
net.input.processFcns = {}; %{'removeconstantrows');
net.output.processFcns = {};
net.divideFcn = '';

% Train the Network
[net,tr] = train(net,x,t);
%Load trained network
%load('sqnl8_dc_motorNet_v1.mat') %2 hidden neurons, mapminmax then
%,ultiply by 100.72, PM = 6 'sqnl8';'sqnl8'
%load('sqnl8_dc_motorNet_v2.mat') %3 hidden neurons, mapminmax then
%,ultiply by 100.72, PM = 6 'sqnl8';'sqnl8'

%load('sqnl8_dc_motorNet_v3.mat') %3 hidden neurons, mapminmax then
%,ultiply by 100.72, PM = 6 'sqnl8';'purelin'

%load('sqnl8_dc_motorNet_v4.mat') %3 hidden neurons, mapminmax then
%,ultiply by 100.72, PM = 6 'sqnl8';'purelin' best result
 
% Test the Network with seen data
y = net(x);
e = gsubtract(t,y);
performance = perform(net,t,y)
figure; plot(t); hold on; plot((y));
legend('Actual','Predicted')
title('Actual Vs Predicted Output for Training/Seen Data-Floating Point')

% Test the Network with unseen data
y_test = net(x_test);
e_test = gsubtract(t_test,y_test);
performance_test = perform(net,t_test,y_test)
% View the Network
% view(net)
figure; plot(y_test); hold on; plot(t_test);
legend('Actual','Predicted')
title('Actual Vs Predicted Output for Test/UnSeen Data-Floating Point')
% Plots
% Uncomment these lines to enable various plots.
%figure, plotperform(tr)
%figure, plottrainstate(tr)
%figure, ploterrhist(e)
%figure, plotregression(t,y)
%figure, plotfit(net,x,t)
net.IW{1,1}
net.LW{2,1}
