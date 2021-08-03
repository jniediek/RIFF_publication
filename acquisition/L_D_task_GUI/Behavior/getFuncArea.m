function area = getFuncArea(x,y, areaTable, centData)

x0 = centData(1);
y0 = centData(2);
R = centData(3);

%find distance from center:
r = sqrt((x-x0)^2+(y0-y)^2);

%if outside the circle
if r > R
    area = -1;
    return;
%if inside inner circle
elseif r <= areaTable.r2(1)
    area = 0; %do nothing (can be changed)
    return;    
else % if inside outer ring
    theta = acos(dot([x-x0,y0-y],[R,0])/(norm([x-x0,y0-y])*norm([R,0])));
    if y0 - y < 0
        theta =  2*pi - theta;
    end
end

theta1 = areaTable.theta1;
t2_idx = areaTable.area(areaTable.theta2 == max(areaTable.theta2));
a = find(theta1 >= theta);
if isempty(a) && theta > areaTable.theta2(t2_idx)
    area = t2_idx;    
else
    area = areaTable.area(areaTable.theta1 == min(theta1(a)));
end


