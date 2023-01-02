function [areaTable, centData] = setFuncArea(inputvector)

loclen = inputvector(1)-3;
locx = inputvector(2:loclen/2+1);
locy = inputvector(loclen/2+2:loclen+1);
x0 = inputvector(loclen+2); % center x
y0 = inputvector(loclen+3); % center y
R = inputvector(loclen+4); % radius
centData = [x0 y0 R];

r1 = R/8;
r2 = 3*R/8; 

areaTable = table();
ar = 0;

for i = 1:loclen/2
    ar = ar+1;
    x = locx(i)-x0;
    y = y0-locy(i);

    theta(ar) = acos(dot([x,y],[R,0])/(norm([x,y])*norm([R,0])));
    if y < 0
        theta(ar) = 2*pi - theta(ar);
    end

    if ar > 1
        theta1 = theta(ar-1);
        theta2 = theta(ar);
        area = ar-1;
        tmpTbl = table(area, theta1, theta2, r1, r2);
        areaTable = [areaTable; tmpTbl];
    end
end
area = ar;
theta1 = theta(ar);
theta2 = theta(1);
tmpTbl = table(area, theta1, theta2, r1, r2);
areaTable = [areaTable; tmpTbl];
cam_data = struct('areaTable',areaTable,'centData',centData,'input',inputvector);
save('cam_data.mat','cam_data');
end