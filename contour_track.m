function [minor,ctr,area,contour,inBlink,isClosed] = contour_track(frame, maxArea, prevMask, prevCenter, origAngle, plotYN, inBlink, iter, zeroCenter, HSVranges, gs)

% This function uses the built in activecontour function from Matlab's
% image processing toolbox, to track the edges of a rodent in a video
% frame.
% 
% The function requires the following inputs:
% frame         - current frame being tracked
% maxArea       - maximal eye area allowed
% prevMask      - binary mask of previous contour detected
% prevCenter    - center coordinates of previous contour detected
% origAngle     - angle of the first contour defined by user
% plotYN        - binary to determine if a plot of ellipse is required
% inBlink       - binary to determine if a blink is in progress
% iter          - number of iterations to be done by activecontour
% zeroCenter    - center coordinates of first contour defined by user
% HSVranges     - ranges of HSV values determined from first frame area
%
% The function returns the minor axis of an ellipse that fits the eye; the
% center coordinates of the contour (ctr), the contour area (area), the
% contour mask (contour), a binary variable determining if a blink is in
% progress (inBlink) and a binary variable determining if the eye is closed
% (isClosed)
%
% © Guy Tsror, McGill Universty, 2018

%% Preprocessing

% defining relevant pixels:

if strcmp(gs,'RGB')==1
    HSVfr = relevant_eye(frame, HSVranges);
    
% Conversion to grayscale:

    I1 = rgb2gray(HSVfr);
else
    HSVfr = relevant_eye_gs(frame, HSVranges);
    I1 = HSVfr;
end
% Morphologically closing, opening and closing again, to reduce gaps
% between relevant pixels and remove outliers

tmp1 = bwmorph(I1,'close');
tmp2 = bwmorph(tmp1,'open');
I = bwmorph(tmp2,'close');

I2 = uint8(255 * I);

clear I1 tmp1 tmp2 I;

% Blurring image with a gaussian filter to lose the smaller irrelevant
% edges

B = imgaussfilt(I2,2);

%% Tracking

% defining the current contour based on previous mask. Activecontour uses
% the number of iterations predefined with 'iter', and uses the prevMask as
% reference.

contour = activecontour(B,prevMask,iter);

% Using 'regionprops' to extract relevant information from the contour area

stats = regionprops('table',contour,'centroid','area','minoraxislength','majoraxislength','orientation');
totElpsFound = size(stats,1);

%% Verification stage - to make sure the ellipse matches the eye rather than noise

% Defining range of possible center coordinates
centerXrange = [prevCenter(1)-50 prevCenter(1)+50];
centerYrange = [prevCenter(2)-25 prevCenter(2)+25];

[minor, ctr, ind, flag, area] = extract_ellipse(origAngle,maxArea,totElpsFound,centerXrange,centerYrange,zeroCenter,stats);
% At this point, output measures received from extract_ellipse describe an
% ellipse that fits the eye OR a NaN, in case no ellipse was found to match


%% Blink stage - handling full blinks happening in the frame:

if isempty(stats)==1
    
    % in this case, the stats table is empty! meaning there were no relevant
    % ellipses found. This means that the eye could be entirely shut, and we
    % we should not try and track any ellipses!
    
    if inBlink == 1
        % indicating that it could be a blink
        isClosed = 1;
        disp('Full closure was detected during a blink');
        pause(0.05)
        contour = prevMask; % getting the output of the function to be its input
    else
        isClosed = 0;
    end
    
elseif area < 0.33*maxArea
    
    % In this case, a part of the eye was identified (stats isnt empty), but it was also
    % significantly smaller compared to the original eye size.
    % meaning the blink is in process right now (eye not completely closed,
    % however is significantly smaller)
    
    inBlink = 1; % set blink marker to 1
    isClosed = 0;
else
    inBlink = 0;
    isClosed = 0;
end

%% Plotting stage - if required only; 

if plotYN == 1 
    if ind == 0
        % this situation means that no ellipses were changed/added, thus we
        % only want to plot the actual video
        plot_ellipse(stats,ind,frame,prevMask,0);        
    elseif flag ~= 1
        % plotting is needed of the ellipse tracked
        plot_ellipse(stats,ind,frame,contour,1);
    else
        % in this case, the ellipse is probably too big/far off; minor axis
        % was not recorded, so it should not be plotted
        plot_ellipse(stats,ind,frame,contour,0);
    end
end

