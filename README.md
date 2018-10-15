# Time_Series_Application
This is a repo containing research work on NN speed control of DC motor using MATLAB. The aim is to implement this on FPGA. 
Overall, we are interested in comparing different architectures, delays, sampling time and finally activation functions.


# Dataset Information
Solver: Ode3 (Fixed step)

Motor Param:

 K=0.0271; 
 
    R=2; 
    
    L=1.8e-3; 
    
    J=0.0000105; 
    
    b=4.5307e-05;  
    
PID :

P 16.57920

I 49.1847

D 0


data_ts_ [] = [u1 output]

i.e. pidin = data_ts_1(:,1) ;

pidout = data_ts_1(:,2) 

data_ts_1 => ts = 0.1

data_ts_01 => ts = 0.01

data_ts_001 => ts = 0.001

data_ts_2 => ts = 0.2
