%motor pole
p =10;

%speed controller
p1 = 40;
i1 = 100;
d1 = 0;

% orientation controller
p2 = 5;
i2 = 0.5;
d2 = 0;

%% deadzone
dz=0.5;

%% wheel diameter 2in, tube diameter 0.25in, total diameter = 2 + 0.25*2 = 2.5in
wdia = 2.5*25.4; %in mm