function [y1,xf1,xf2] = sqnl8_dc_mFunc(x1,x2,xi1,xi2)
%SQNL8_DC_MFUNC neural network simulation function.
%
% Generated by Neural Network Toolbox function genFunction, 30-Oct-2018 13:05:14.
% 
% [y1,xf1,xf2] = sqnl8_dc_mFunc(x1,x2,xi1,xi2) takes these arguments:
%   x1 = 1xTS matrix, input #1
%   x2 = 1xTS matrix, input #2
%   xi1 = 1x2 matrix, initial 2 delay states for input #1.
%   xi2 = 1x2 matrix, initial 2 delay states for input #2.
% and returns:
%   y1 = 1xTS matrix, output #1
%   xf1 = 1x2 matrix, final 2 delay states for input #1.
%   xf2 = 1x2 matrix, final 2 delay states for input #2.
% where TS is the number of timesteps.

% ===== NEURAL NETWORK CONSTANTS =====

% Input 1
x1_step1.xoffset = -1.92985026416746;
x1_step1.gain = 0.0385134944511873;
x1_step1.ymin = -1;

% Input 2
x2_step1.xoffset = 28.4829682709601;
x2_step1.gain = 0.0634577525318539;
x2_step1.ymin = -1;

% Layer 1
b1 = [-11.854043457545179407;-9.9351848411448191456;100.66183188979388774];
IW1_1 = [54.194370941942722197 -44.594693633263368326;53.966546250589267686 -44.37739093913544508;48.380163631578064098 18.079404754283036283];
IW1_2 = [-44.940108443611677558 18.244875888937954755;-44.401913360708050504 17.998740535448355615;-102.27616120329028604 -10.546059007793324724];

% Layer 2
b2 = -5.7359893819130345349;
LW2_1 = [-3.3068733979623821106 3.3527002407110662041 -0.010181620476151924046];

% Output 1
y1_step1.ymin = -1;
y1_step1.gain = 0.0634577525318539;
y1_step1.xoffset = 28.4829682709601;

% ===== SIMULATION ========

% Dimensions
TS = size(x1,2); % timesteps

% Input 1 Delay States
xd1 = mapminmax_apply(xi1,x1_step1);
xd1 = [xd1 zeros(1,1)];

% Input 2 Delay States
xd2 = mapminmax_apply(xi2,x2_step1);
xd2 = [xd2 zeros(1,1)];

% Allocate Outputs
y1 = zeros(1,TS);

% Time loop
for ts=1:TS

      % Rotating delay state position
      xdts = mod(ts+1,3)+1;
    
    % Input 1
    xd1(:,xdts) = mapminmax_apply(x1(:,ts),x1_step1);
    
    % Input 2
    xd2(:,xdts) = mapminmax_apply(x2(:,ts),x2_step1);
    
    % Layer 1
    tapdelay1 = reshape(xd1(:,mod(xdts-[1 2]-1,3)+1),2,1);
    tapdelay2 = reshape(xd2(:,mod(xdts-[1 2]-1,3)+1),2,1);
    a1 = sqnl8_apply(b1 + IW1_1*tapdelay1 + IW1_2*tapdelay2);
    
    % Layer 2
    a2 = b2 + LW2_1*a1;
    
    % Output 1
    y1(:,ts) = mapminmax_reverse(a2,y1_step1);
end

% Final delay states
finalxts = TS+(1: 2);
xits = finalxts(finalxts<=2);
xts = finalxts(finalxts>2)-2;
xf1 = [xi1(:,xits) x1(:,xts)];
xf2 = [xi2(:,xits) x2(:,xts)];
end

% ===== MODULE FUNCTIONS ========

% Map Minimum and Maximum Input Processing Function
function y = mapminmax_apply(x,settings)
  y = bsxfun(@minus,x,settings.xoffset);
  y = bsxfun(@times,y,settings.gain);
  y = bsxfun(@plus,y,settings.ymin);
end

% Square Law -8bit Transfer Function
function a = sqnl8_apply(n,~)
a=zeros(size(n));
idx = find(n > 128);
n(idx) = 128;
idx = find(n < -128);
n(idx) = -128;
idx = find(n >= 0);
a(idx) = n(idx) - n(idx).^2/256;
idx = find(n < 0);
a(idx) = n(idx) + n(idx).^2/256;
end

% Map Minimum and Maximum Output Reverse-Processing Function
function x = mapminmax_reverse(y,settings)
  x = bsxfun(@minus,y,settings.ymin);
  x = bsxfun(@rdivide,x,settings.gain);
  x = bsxfun(@plus,x,settings.xoffset);
end