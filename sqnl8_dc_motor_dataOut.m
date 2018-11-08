%Printing the value of PID data set for simulation in Modelsim (18 bits
%fixed point)
%Author: Adedamola Wuraola
%Date: 13/09/2017
p1 = pv;
r11=p1(:,1);

for r=2:30000
    r11=[r11;p1(:,r)];   
end
r11bin=bin(r11);

fid = fopen('D:\bs5\macros\NNpid.tcl','w');

[row, col] = size(r11bin);
j=1;

for x=1:60000  %size of column of p1 before converting to binary
    if j>2   %size of row
        j=1;
    end

    
    fprintf(fid,'force x');
       
                fprintf(fid,'%d ',j);
           
                
    for y=1:col
        fprintf(fid,'%s',r11bin(x,y));
    end
    
    j=j+1;
    if j==3
                 
    fprintf(fid,'\n');
     fprintf(fid,'run 400us');  
    end
           
    fprintf(fid,'\n');
end
fclose(fid);