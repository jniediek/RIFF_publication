a = ['C:\logging_data\14-06-2017Test\bg_s1.tif'];
frame = imread(a);
imshow(a, 'Border', 'tight');
[x, y] = getpts;
x = round(x);
y = round(y);
size = 10;
rect = frame(y-size:y+size, x-size:x+size);
D = regionprops(rect == max(max(rect)), 'Centroid');
p = round(D.Centroid);
hold on; 
h1 = plot(x+p(1)-11, y+p(2)-11, 'r*', 'LineWidth', 3, 'MarkerSize', 5);
 figure; imshow(frame(y+p(2)-11*2:y+p(2), x+p(1)-11*2:x+p(1)), 'Border', 'tight')
