%% This script is to empirically determine the effect of simulation fixed step size on the accuracy, architecture
% on neural network replacement of PID in dc motor speed control
%% Start the initial weight from the same seed for comparison sake 

RandStream.setGlobalStream (RandStream ('mrg32k3a','Seed', 1234)); %remove, just for testing initial weights
load('data_ts_01.mat')
pidin = data_ts_01(:,1);
pidout = data_ts_01(:,2);

%Normalization of inputs and targets
xmin= min(pidin);
xmax= max(pidin);
twothird = round((2/3)*N); %for training data
ymin= min(pidout);
ymax= max(pidout);
pidin_train = pidin(1:twothird,:);
pidout_train = pidout(1:twothird,:);
[I N] = size(pidin_train');
[O N] = size(pidout_train');
MSE00 = var(pidout_train,1)
pidin_test = pidin(twothird+1:end,:);
pidout_test = pidout(twothird+1:end,:);

pidin_norm =  mapminmax_forward_x(pidin_train,xmin,xmax);
pidout_norm = mapminmax_forward_y(pidout_train,ymin,ymax);
X = tonndata(pidin_norm,false,false);
T = tonndata(pidout_norm,false,false);

Ntrn = N-2*round(0.15*N);
trnind = 1:Ntrn;
Ttrn = T(trnind);
Neq  = prod(size(Ttrn));
FD   = 1:20; %Random Selection of feedback delay (feedbackDelays)
ID   = 1:20; %Random selection of input delay (inputDelays)

NFD  = length(FD);
NID  = length(ID);
MXFD  = max(FD);      
MXID = max(ID);
Ntrneq = prod(size(pidout_train));
Hub     =  -1+ceil( (Ntrneq-O) / ((NID*I)+(NFD*O)+1));
Hmax    =  floor(Hub/10) %  
%Hmax = 2 ==>  Nseq >>Nw :
Hmin    = 0;
dH      = 1;
Ntrials = 2;
j=0;
rng(2)
% Choose a Training Function
 trainFcn = 'trainlm';  % Levenberg-Marquardt backpropagation.
for h = Hmin:dH:Hmax
    j = j+1
    if h == 0
        net = narxnet(ID,FD,[]);
        %net.initFcn='initlay';  %remove, just for testing initial weights
        %net.layers.transferFcn={'tansig';'purelin'};
        Nw =  ( NID*I + NFD*O + 1)*O;
    else
         net = narxnet( ID, FD, h );
         %net.initFcn='initlay';  %remove, just for testing initial weights
         %net.layers.transferFcn={'tansig';'purelin'};
         Nw =  ( NID*I + NFD*O + 1)*h + ( h + 1)*O;
    end
    Ndof = Ntrn-Nw;
    [ Xs Xi Ai Ts ] = preparets(net,X,{},T);
    ts              = cell2mat(Ts);
    xs              = cell2mat(Xs);
    MSE00s          = mean(var(ts',1))
    MSE00as         = mean(var(ts'))
    MSEgoal         = 0.01*Ndof*MSE00as/Neq
    MinGrad         = MSEgoal/10
    net.trainParam.goal      =  MSEgoal;
    net.trainParam.min_grad  =  MinGrad;
    net.divideFcn            =  'dividetrain';
    for i = 1:Ntrials
          net            =  configure(net,Xs,Ts);
          [net ,tr, Ys]  =  train(net,Xs,Ts,Xi,Ai);
          ys             =  cell2mat(Ys);
          stopcrit{i,j}  = tr.stop;
          bestepoch(i,j) = tr.best_epoch;
          MSE            = mse(ts-ys);
          MSEa           = Neq*MSE/Ndof;
          R2(i,j)        = 1-MSE/MSE00s; 
          R2a(i,j)       = 1-MSEa/MSE00as;
    end
end
   
   
stopcrit   =  stopcrit    %Min grad reached (for all).
bestepoch  =  bestepoch
R2         =  R2
R2a        =  R2a
