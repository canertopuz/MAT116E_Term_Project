% Calculate distances between a point and another points
function distance= distCenterBorder(center,border)
[row, ~] = size(border); 
distance = zeros(row,1);

for i=1:row
distance(i) = sqrt((center(1) - border(i,1))^2 + (center(2) - border(i,2))^2);
end