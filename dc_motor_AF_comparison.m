load('pid_output.mat')
load('PID_input.mat')

pidin_train = pidin(1:190000,:);
pidout_train = pidout(1:190000,:);
pidin_test = pidin(190001:end,:);
pidout_test = pidout(190001:end,:);
a=1;
b=-1;
% pidin_norm = a+(b-a)*(pidin_train-min(pidin_train))/( max(pidin_train)-min(pidin_train));
% pidout_norm = a+(b-a)*(pidout_train-min(pidout_train))/( max(pidout_train)-min(pidout_train));
%y = (ymax-ymin)*(x-xmin)/(xmax-xmin) + ymin;
[pidin_norm, ps] =  mapminmax(pidin_train');
[pidout_norm,tsn] = mapminmax(pidout_train');
X = tonndata(pidin_norm',false,false);
T = tonndata(pidout_norm',false,false);
%Testing: Unseen data
Xtest = tonndata(pidin_test,false,false);
Ttest = tonndata(pidout_test,false,false);

% Choose a Training Function
 trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.

% Create a Nonlinear Autoregressive Network with External Input
inputDelays = 1:4;
feedbackDelays = 1:4;
hiddenLayerSize = 10;
count = 100; %epoch
goal = 0.0;
mingrad = 1e-500;
numNN = 3; %repetition

H = hiddenLayerSize;
for i = 1:numNN
net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize,'open',trainFcn);
[x,xi,ai,t] = preparets(net,X,{},T);
netelliot = net;
netelliot.layers.transferFcn={'elliotsig';'purelin'};
netelliot.output.processFcns = {};
netelliot.divideFcn = '';
netelliot.trainParam.goal = goal;
netelliot.trainParam.epochs = count;
netelliot.trainParam.min_grad = mingrad;

netsqnl = net;
netsqnl.layers.transferFcn={'sqnl';'purelin'};
netsqnl.output.processFcns = {};
netsqnl.divideFcn = '';
netsqnl.trainParam.goal = goal;
netsqnl.trainParam.epochs = count;
netsqnl.trainParam.min_grad = mingrad;


nettansig = net;
nettansig.layers.transferFcn={'tansig';'purelin'};
nettansig.output.processFcns = {};
nettansig.divideFcn = '';
nettansig.trainParam.goal = goal;
nettansig.trainParam.epochs = count;
nettansig.trainParam.min_grad = mingrad;


netrelu = net;
netrelu.layers.transferFcn={'relu';'purelin'};
netrelu.output.processFcns = {};
netrelu.divideFcn = '';
netrelu.trainParam.goal = goal;
netrelu.trainParam.epochs = count;
netrelu.trainParam.min_grad = mingrad;

NNelliot = cell(1, numNN);
NNsqnl = cell(1, numNN);
NNtansig = cell(1, numNN);
NNrelu = cell(1, numNN);
perfs = zeros(1, numNN);

   % fprintf('Training %d/%d\n', i , numNN);[net,tr] = train(net,x,t,xi,ai);
    [NNelliot{i}, trelliot{i}] = train(netelliot,x,t,xi,ai);
    [NNsqnl{i}, trsqnl{i}] = train(netsqnl,x,t,xi,ai);
    [NNtansig{i}, trtansig{i}] = train(nettansig,x,t,xi,ai);
    [NNrelu{i}, trrelu{i}] = train(netrelu,x,t,xi,ai);
    %y2 = NN{i}(x2); % same as y2 = sim(NN{i},x2); net(x,xi,ai);
    y1elliot = NNelliot{i}(x,xi,ai);
    y1sqnl = NNsqnl{i}(x,xi,ai);
    y1tansig = NNtansig{i}(x,xi,ai);
    y1relu = NNrelu{i}(x,xi,ai);
%     a = mapminmax('reverse',y,tsn);
%     e = gsubtract(t,y);


    perfselliottrain(i) = perform(netelliot, t, y1elliot);
    perfssqnltrain(i) = perform(netsqnl, t, y1sqnl);
    perfstansigtrain(i) = perform(nettansig, t, y1tansig);
    perfsrelutrain(i) = perform(netrelu, t, y1relu);
    
    
    %Testing
    pidin_test_norm =mapminmax('apply',pidin_test,ps);
    pidout_test_norm =mapminmax('apply',pidout_test,tsn);
    Xtest = tonndata(pidin_test_norm,false,false);
    Ttest = tonndata(pidout_test_norm ,false,false);
    [x_test,xi_test,ai_test,t_test] = preparets(net,Xtest,{},Ttest);
    
    
    
    ytestelliot = NNelliot{i}(x_test,xi_test,ai_test);
    ytestsqnl = NNsqnl{i}(x_test,xi_test,ai_test);
    ytesttansig = NNtansig{i}(x_test,xi_test,ai_test);
    ytestrelu = NNrelu{i}(x_test,xi_test,ai_test);
    perfselliottest(i) = perform(netelliot, t_test, ytestelliot);
    perfssqnltest(i) = perform(netsqnl, t_test, ytestsqnl);
    perfstansigtest(i) = perform(nettansig, t_test, ytesttansig);
    perfsrelutest(i) = perform(netrelu, t_test, ytestrelu);
    
    
     epochelliot1(i) = trelliot{1,i}.num_epochs;
     epochsqnl1(i) = trsqnl{1,i}.num_epochs;
     epochtansig1(i) = trtansig{1,i}.num_epochs;
     epochrelu1(i) = trrelu{1,i}.num_epochs;
    
    
     epochelliot = trelliot{1,i}.num_epochs;
     epochsqnl = trsqnl{1,i}.num_epochs;
     epochtansig = trtansig{1,i}.num_epochs;
     epochrelu = trrelu{1,i}.num_epochs;
     minperfselliottrain = find(perfselliottrain==min(perfselliottrain));
     minperfssqnltrain = find(perfssqnltrain==min(perfssqnltrain));
     minperfstansigtrain = find(perfstansigtrain==min(perfstansigtrain));
     minperfsrelutrain = find(perfsrelutrain==min(perfsrelutrain));
     
     minperfselliottest = find(perfselliottest==min(perfselliottest));
     minperfssqnltest = find(perfssqnltest==min(perfssqnltest));
     minperfstansigtest = find(perfstansigtest==min(perfstansigtest));
     minperfsrelutest = find(perfsrelutest==min(perfsrelutest));
     
     fprintf('Training %d/%d, %d, %d, %d, %d\n', i , numNN, epochelliot, epochsqnl, epochtansig, epochrelu);
end
% minperfselliottrain
% minperfssqnltrain
% minperfstansigtrain


minperfselliottest
minperfssqnltest
minperfstansigtest
minperfsrelutest

% perfselliottrain
% perfssqnltrain
% perfstansigtrain


perfselliottest
perfssqnltest
perfstansigtest
perfsrelutest
 
meanpefelliottrain = mean(perfselliottrain)
meanpefsqnltrain = mean(perfssqnltrain)
meanpeftansigtrain = mean(perfstansigtrain)
meanpefrelutrain = mean(perfsrelutrain)

meanpefelliottest = mean(perfselliottest)*100
meanpefsqnltest = mean(perfssqnltest)*100
meanpeftansigtest = mean(perfstansigtest)*100
meanpefrelutest = mean(perfsrelutest)*100
mean(epochelliot1)
mean(epochsqnl1)
mean(epochtansig1)
mean(epochrelu1)

