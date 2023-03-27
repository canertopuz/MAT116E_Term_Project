% Caner Topuz
% 090200358
% MAT116E Term Project
clear;
close all;
clc;
colors=['b','g','r','c','m','y'];
objectTypes = {'Circle','Rectangle',"Couldn't found"};
varNames = {'Object Number','Circularity','dA','dB','S(area)','dM','rS','rL','Object Type'};

% Read image and display
im_org= imread("test5.png");
subplot(2,2,1)
hold on;
imshow(im_org);
title('1-Original Image');

% Check monochrome or not
[row, col, numberOfColorBands] = size(im_org);
if numberOfColorBands > 1
	im_gray = rgb2gray(im_org);
else
    im_gray = im_org;
end

% Binarize the image and check nuber of white pixels -> is it more than black pixels?
im_bin = imbinarize(im_gray);
if sum(im_bin,'all') > row*col/2
    % If answer is yes, then change zeros and ones
    im_bin = not(im_bin);
end

% Display binarize image
subplot(2,2,2)
imshow(im_bin);
title('2-Binarize Image');

% Remove small objects
im_bin = bwareaopen(im_bin,200);

% Display it
subplot(2,2,3)
imshow(im_bin);
title('3-Cleared Binarize Image');

% Fill the holes and display it
filledImage = imfill(im_bin,'holes');
subplot(2,2,4)
imshow(filledImage);
title('4-Filled Image');
hold off;

% Determine the objects and collect some of measurements
[~, numberOfObjects] = bwlabel(filledImage);
blobMeasurements = regionprops(filledImage,'Centroid','Perimeter','Area');
allAreas = [blobMeasurements.Area];
allPerimeters = [blobMeasurements.Perimeter];
allCircularity = (allPerimeters .^ 2) ./ (4 * pi * allAreas);

% Set the size of arrays
rS = zeros(numberOfObjects,1);
rL = zeros(numberOfObjects,1);
bDist = zeros(numberOfObjects,1);
minDist = zeros(numberOfObjects,1);
maxDist = zeros(numberOfObjects,1);
objectType = strings(numberOfObjects,1);

% Get the bounderies
B = bwboundaries(filledImage);

% Display the original image in a different window
figure;
image(im_org);
hold on;
title('Result');
for k=1:numberOfObjects
    bound = B{k};
    cidx = mod(k,length(colors))+1;
    
    % Outline the object and give a number
    plot(bound(:,2),bound(:,1),'r','LineWidth',3);
    h = text(blobMeasurements(k).Centroid(1),blobMeasurements(k).Centroid(2), num2str(k));
    set(h,'Color',colors(cidx),'FontSize',14,'FontWeight','bold');
    
    % Swap the first column with the second column
    trsh = bound(:,1);
    bound(:,1) = bound(:,2);
    bound(:,2) = trsh;
     
    center = blobMeasurements(k).Centroid;
    
    %  Calculate the distance of each border pixel to the centroid; find the 
    % minimal distance minDist, and the maximal distance maxDist, remember the coordinates of the point
    % a which has the minimal distance, and the point which has the maximal distance.
    dist = distCenterBorder(center,bound);
    [minDist(k),minIndx] = min(dist);
    [maxDist(k),maxIndx] = max(dist);
    minCoord = bound(minIndx,:);
    maxCoord = bound(maxIndx,:);
    
    % Determine the point b and the distance between center and b
    [~,bIndx] = minSlopeCenterBorder(center,bound,minCoord);
    bCoord = bound(bIndx,:);
    bDist(k) = distCenterBorder(center,bCoord);
     
    % Calculate the enclosed area of the boundary.
    areaCalculated = 4*minDist(k)*bDist(k);
    
    % Calculate half the length of the diagonal
    halfDiognalCalculated = sqrt(minDist(k)^2 + bDist(k)^2);
    areaReal = allAreas(k);
    
    % Calculate rS and rL
    rS(k) = abs((areaReal - areaCalculated) / areaReal);
    rL(k) = abs((maxDist(k) - halfDiognalCalculated) / maxDist(k));

    % Plot dB,dA,dM
    line([center(1),bCoord(1)],[center(2),bCoord(2)],'color','magenta','LineStyle','-.','LineWidth',1.5);
    line([center(1),minCoord(1)],[center(2),minCoord(2)],'color','green','LineStyle','-.','LineWidth',1.5);
    line([center(1),maxCoord(1)],[center(2),maxCoord(2)],'color','blue','LineStyle','-.','LineWidth',1.5);
    legend('','dB','dA','dM');
    
    %  By using previous data determine whether an object is a rectangle or a circle
    if allCircularity(k) < 1.05 && allCircularity(k) > 0.95
        objectType(k) = objectTypes(1);
    elseif rS(k)<0.1 && rL(k)<0.05
        objectType(k) = objectTypes(2);
    else
        objectType(k) = objectTypes(3);
    end
end

% Create table and display the results
T = table((1:numberOfObjects)',allCircularity',minDist,bDist,allAreas',maxDist,rS,rL,objectType,'VariableNames',varNames);
disp(T);
fig = uifigure('Name','Detection data and results','Position',[500 500 1020 480]);
uit = uitable('Parent',fig,'Position',[10 20 1000 450]);
uit.Data = T;

s = uistyle('BackgroundColor','r','FontWeight','bold');
s1 = uistyle('FontWeight','bold');
addStyle(uit,s,'column',9);
addStyle(uit,s1,"column",1);