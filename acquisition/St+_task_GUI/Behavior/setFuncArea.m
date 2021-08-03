function [areaTable, centData] = setFuncArea(inputvector)
loclen = inputvector(1)-3;
locx = inputvector(2:loclen/2+1);
locy = inputvector(loclen/2+2:loclen+1);
x0 = round(mean(locx));%inputvector(loclen+2); % center x
y0 = round(mean(locy));%inputvector(loclen+3); % center y
R = inputvector(loclen+4); % radius another option: round(mean(pdist2([x0 y0],[locx locy])));
centData = [x0 y0 R];
r1 = R*0.475;
r2 = R*(0.3125+0.475);
areaTable = table();
ar = 0;
areaN = [1 1 2 2 3 3 4 4 5 5 6 6];
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
        idx = ar-1;
        area = areaN(ar-1);
        tmpTbl = table(idx, area, theta1, theta2, r1, r2);
        areaTable = [areaTable; tmpTbl];
    end
end
idx = ar;
area = areaN(ar);
theta1 = theta(ar);
theta2 = theta(1);
tmpTbl = table(idx, area, theta1, theta2, r1, r2);
areaTable = [areaTable; tmpTbl];
areatype = categorical({'1';'C';'2';'C';'3';'C';'4';'C';'5';'C';'6';'C';}); %important: need to start areas from Area #1
areatype = table(areatype);
areaTable = [areatype areaTable];
cam_data = struct('areaTable',areaTable,'centData',centData,'input',inputvector);
save('cam_data.mat','cam_data');
end