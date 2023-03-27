
function [minSlope,indx] = minSlopeCenterBorder(center,border,minPoint)
[row, ~] = size(border); 
slope = zeros(row,1);
minPointSlope = (minPoint(2) - center(2)) / (minPoint(1) - center(1));

for i=1:row
    slope_t = (border(i,2) - center(2)) / (border(i,1) - center(1));
    slope(i) = abs(slope_t*minPointSlope+1);
end

[minSlope, indx] = min(slope);

end