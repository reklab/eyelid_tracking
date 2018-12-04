function [ctrCoor,maxArea,expandedContour,angle,Xs,Ys,HSVRanges] = eye_edge_adv(frame,userYN,Xs,Ys,prevMask)

% This function is used in the initialization process of the eye tracking
% using edge detection and active contour tracking. 
% It lets the user pick the eye area from the first frame of the video that
% will be used as the mask for later frames.
% userYN- should be 1 or other. If 1, user input required (to set eye egde
% Xs    - X coordinates of the contour if user input not required. 
% Ys    - Y coordinates of the contour if user input not required.
% prevMask - previous contour in image form, when user input not required.


if userYN == 1
    imshow(frame)
    [prevMask, Xs, Ys] = roipoly();
    close all
end

% The added step: Letting the user choice to exapnd towards the eye
% borders:
expandedContour = activecontour(rgb2gray(frame),prevMask,15);


% Extracting key features from selected contour area:

stats = regionprops('table',expandedContour,'centroid','area','orientation');

% Finding relevant pixel values:

ind1 = find(expandedContour==1);
ind2 = ind1+(size(expandedContour,1))*(size(expandedContour,2));
ind3 = ind2+(size(expandedContour,1))*(size(expandedContour,2));

% Conversion to HSV from RGB

hsvFr = rgb2hsv(frame);
hVals = hsvFr(ind1);
sVals = hsvFr(ind2);
vVals = hsvFr(ind3);

% Extracting mean and std values for HSV matrices

meanH = mean(hVals);
stdH = std(hVals);
meanS = mean(sVals);
stdS = std(sVals);
meanV = mean(vVals);
stdV = std(vVals);

% Defining return values:

HSVRanges = [meanH, stdH; meanS, stdS; meanV, stdV];
ctrCoor = [stats.Centroid(1), stats.Centroid(2)];
angle = stats.Orientation;
maxArea = (stats.Area)*1.1;