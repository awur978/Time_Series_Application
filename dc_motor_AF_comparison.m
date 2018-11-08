load('data_ts_01.mat')
pidin = data_ts_01(:,1);
pidout = data_ts_01(:,2);

[I, ~] = size(pidin');
[O, N] = size(pidout');
twothird = round((2/3)*N); %for training data
pidin_train = pidin(1:twothird,:);
pidout_train = pidout(1:twothird,:);
pidin_test = pidin(twothird+1:end,:);
pidout_test = pidout(twothird+1:end,:);

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
inputDelays = 1:2;
feedbackDelays = 1:2;
hiddenLayerSize = 6;
count = 500; %epoch
goal = 2.52e-6;%0.000001;
mingrad = 1e-500;
numNN = 100; %repetition

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

netlrelu = net;
netlrelu.layers.transferFcn={'lrelu';'purelin'};
netlrelu.output.processFcns = {};
netlrelu.divideFcn = '';
netlrelu.trainParam.goal = goal;
netlrelu.trainParam.epochs = count;
netlrelu.trainParam.min_grad = mingrad;

netelu = net;
netelu.layers.transferFcn={'elu';'purelin'};
netelu.output.processFcns = {};
netelu.divideFcn = '';
netelu.trainParam.goal = goal;
netelu.trainParam.epochs = count;
netelu.trainParam.min_grad = mingrad;

netsqlu = net;
netsqlu.layers.transferFcn={'sqlu';'purelin'};
netsqlu.output.processFcns = {};
netsqlu.divideFcn = '';
netsqlu.trainParam.goal = goal;
netsqlu.trainParam.epochs = count;
netsqlu.trainParam.min_grad = mingrad;

NNelliot = cell(1, numNN);
NNsqnl = cell(1, numNN);
NNtansig = cell(1, numNN);
NNrelu = cell(1, numNN);
NNsqlu = cell(1, numNN);
NNelu = cell(1, numNN);
NNlrelu = cell(1, numNN);
perfs = zeros(1, numNN);

   % fprintf('Training %d/%d\n', i , numNN);[net,tr] = train(net,x,t,xi,ai);
    [NNelliot{i}, trelliot{i}] = train(netelliot,x,t,xi,ai);
    [NNsqnl{i}, trsqnl{i}] = train(netsqnl,x,t,xi,ai);
    [NNtansig{i}, trtansig{i}] = train(nettansig,x,t,xi,ai);
    [NNrelu{i}, trrelu{i}] = train(netrelu,x,t,xi,ai);
    [NNsqlu{i}, trsqlu{i}] = train(netsqlu,x,t,xi,ai);
    [NNelu{i}, trelu{i}] = train(netelu,x,t,xi,ai);
    [NNlrelu{i}, trlrelu{i}] = train(netlrelu,x,t,xi,ai);
    %y2 = NN{i}(x2); % same as y2 = sim(NN{i},x2); net(x,xi,ai);
    y1elliot = NNelliot{i}(x,xi,ai);
    y1sqnl = NNsqnl{i}(x,xi,ai);
    y1tansig = NNtansig{i}(x,xi,ai);
    y1relu = NNrelu{i}(x,xi,ai);
    y1sqlu = NNsqlu{i}(x,xi,ai);
    y1elu = NNelu{i}(x,xi,ai);
    y1lrelu = NNlrelu{i}(x,xi,ai);
%     a = mapminmax('reverse',y,tsn);
%     e = gsubtract(t,y);


    perfselliottrain(i) = perform(netelliot, t, y1elliot);
    perfssqnltrain(i) = perform(netsqnl, t, y1sqnl);
    perfstansigtrain(i) = perform(nettansig, t, y1tansig);
    perfsrelutrain(i) = perform(netrelu, t, y1relu);
    perfssqlutrain(i) = perform(netsqlu, t, y1sqlu);
    perfselutrain(i) = perform(netelu, t, y1elu);
    perfslrelutrain(i) = perform(netlrelu, t, y1lrelu);
    
    
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
    ytestsqlu = NNsqlu{i}(x_test,xi_test,ai_test);
    ytestelu = NNelu{i}(x_test,xi_test,ai_test);
    ytestlrelu = NNlrelu{i}(x_test,xi_test,ai_test);
    
    perfselliottest(i) = perform(netelliot, t_test, ytestelliot);
    perfssqnltest(i) = perform(netsqnl, t_test, ytestsqnl);
    perfstansigtest(i) = perform(nettansig, t_test, ytesttansig);
    perfsrelutest(i) = perform(netrelu, t_test, ytestrelu);
    perfssqlutest(i) = perform(netsqlu, t_test, ytestsqlu);
    perfselutest(i) = perform(netelu, t_test, ytestelu);
    perfslrelutest(i) = perform(netlrelu, t_test, ytestlrelu);
    
    
     epochelliot1(i) = trelliot{1,i}.num_epochs;
     epochsqnl1(i) = trsqnl{1,i}.num_epochs;
     epochtansig1(i) = trtansig{1,i}.num_epochs;
     epochrelu1(i) = trrelu{1,i}.num_epochs;
     epochsqlu1(i) = trsqlu{1,i}.num_epochs;
     epochelu1(i) = trelu{1,i}.num_epochs;
     epochlrelu1(i) = trlrelu{1,i}.num_epochs;
    
    
     epochelliot = trelliot{1,i}.num_epochs;
     epochsqnl = trsqnl{1,i}.num_epochs;
     epochtansig = trtansig{1,i}.num_epochs;
     epochrelu = trrelu{1,i}.num_epochs;
     epochsqlu = trsqlu{1,i}.num_epochs;
     epochelu = trelu{1,i}.num_epochs;
     epochlrelu = trlrelu{1,i}.num_epochs;
     minperfselliottrain = find(perfselliottrain==min(perfselliottrain));
     minperfssqnltrain = find(perfssqnltrain==min(perfssqnltrain));
     minperfstansigtrain = find(perfstansigtrain==min(perfstansigtrain));
     minperfsrelutrain = find(perfsrelutrain==min(perfsrelutrain));
     minperfssqlutrain = find(perfssqlutrain==min(perfssqlutrain));
     minperfselutrain = find(perfselutrain==min(perfselutrain));
     minperfslrelutrain = find(perfslrelutrain==min(perfslrelutrain));
     
     minperfselliottest = find(perfselliottest==min(perfselliottest));
     minperfssqnltest = find(perfssqnltest==min(perfssqnltest));
     minperfstansigtest = find(perfstansigtest==min(perfstansigtest));
     minperfsrelutest = find(perfsrelutest==min(perfsrelutest));
     minperfssqlutest = find(perfssqlutest==min(perfssqlutest));
     minperfselutest = find(perfselutest==min(perfselutest));
     minperfslrelutest = find(perfslrelutest==min(perfslrelutest));
     
     fprintf('Training %d/%d, %d, %d, %d,  %d, %d, %d, %d\n', i , numNN, epochelliot, epochsqnl, epochtansig, epochrelu, epochsqlu, epochelu, epochlrelu);
end
% minperfselliottrain
% minperfssqnltrain
% minperfstansigtrain

% 
% minperfselliottest
% minperfssqnltest
% minperfstansigtest
% minperfsrelutest
% minperfssqlutest
% minperfselutest
% minperfslrelutest

% perfselliottrain
% perfssqnltrain
% perfstansigtrain


% perfselliottest
% perfssqnltest
% perfstansigtest
% perfsrelutest
% perfssqlutest
% perfselutest
% perfslrelutest
 
% meanpefelliottrain = mean(perfselliottrain)
% meanpefsqnltrain = mean(perfssqnltrain)
% meanpeftansigtrain = mean(perfstansigtrain)
% meanpefrelutrain = mean(perfsrelutrain)
% meanpefsqlutrain = mean(perfssqlutrain)
% meanpefelutrain = mean(perfselutrain)
% meanpeflrelutrain = mean(perfslrelutrain)

meanpefelliottest = mean(perfselliottest)*100
meanpefsqnltest = mean(perfssqnltest)*100
meanpeftansigtest = mean(perfstansigtest)*100
meanpefrelutest = mean(perfsrelutest)*100
meanpefsqlutest = mean(perfssqlutest)*100
meanpefelutest = mean(perfselutest)*100
meanpeflrelutest = mean(perfslrelutest)*100

mean(epochelliot1)
mean(epochsqnl1)
mean(epochtansig1)
mean(epochrelu1)
mean(epochsqlu1)
mean(epochelu1)
mean(epochlrelu1)

