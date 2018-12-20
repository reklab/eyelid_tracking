function [ctrCoor,maxArea,expandedContour,angle,HSVRanges] = init_partition(frame,user_init,gs)

% This function is used in the initialization process of the eye tracking
% using edge detection and active contour tracking, in a given partition of
% the signal.
%
% It takes in the relevant frame and the user chosen area from which active contour will expand to
% fit the eye. The result of the active contour expansion will be used as
% the mask for consecutive frames.

% The added step: Letting the user choice to exapnd towards the eye
% borders:
if strcmp(gs,'RGB')==1
    % if its an rgs input
    expandedContour = activecontour(rgb2gray(frame),user_init,15);
else
    expandedContour = activecontour(frame,user_init,15);
end


% Extracting key features from selected contour area:

stats = regionprops('table',expandedContour,'centroid','area','orientation');

% Finding relevant pixel values:

ind1 = find(expandedContour==1);
ind2 = ind1+(size(expandedContour,1))*(size(expandedContour,2));
ind3 = ind2+(size(expandedContour,1))*(size(expandedContour,2));

% Conversion to HSV from RGB

if strcmp(gs,'RGB')==1
    hsvFr = rgb2hsv(frame);
else
    hsvFr = rgb2hsv(cat(3, frame, frame, frame));
end

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