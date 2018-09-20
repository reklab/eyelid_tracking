function [minor, ctr, ind, flag, area] = extract_ellipse(origAngle, maxArea, totElpsFound, centerXrange, centerYrange, zeroCenter, stats)


% This function examines ellipses detected in the frame, selects the
% ellipse that could fit the eye area and extracts parameters from it.
%
% Inputs required:
% origAngle         - angle of first contour detected by user
% maxArea           - maximal area allowed
% totElpsFound      - number of ellipses found by regionprops
% centerX/Yrange    - center coordinates allowed, based on original contour
% zeroCenter        - original center coordinates
% stats             - structure containing info of all ellipses detected
%
% The function returns the right ellipse's minor axis (minor), center
% coordinates (ctr) and area (area), as well as the index of the ellipse in
% stats (ind) and a flag marked as 1 in case no ellipse was found.
%
% © Guy Tsror, McGill University, 2018

flag=0;
j=1;
ind = 0;
prevCenter = [centerXrange(1)+50, centerYrange(1)+25];


if totElpsFound > 0
    while j <= totElpsFound
        [area, ind] = max(stats.Area);
        angle = stats.Orientation(ind);
        newCenter = stats.Centroid(ind,:);
        if...
                ((newCenter(1) >= centerXrange(1) && newCenter(1) <= centerXrange(2)...
                && newCenter(2) >= centerYrange(1) && newCenter(2) <= centerYrange(2))...
                || (newCenter(1) >= zeroCenter(1)-50 && newCenter(1) <= (zeroCenter(1)+50)...
                && newCenter(2) >= zeroCenter(2)-25 && newCenter(2) <= (zeroCenter(2)+50)))...
                && area<=1.333*maxArea ...
                && (angle <= (origAngle+10) || angle > (origAngle - 10))
            % the above condition checks all features to be within range
            % from original eye features
            
            break
        else
            if area>=1.1*maxArea
                % flagging
                flag = 1;
                break;
            elseif angle >= (origAngle+10) || angle < (origAngle - 10)
                flag = 1;
                break;
            end
            
            % if its not the case, it's a far off ellipse so we would
            % like to eliminate the center candidate and pick the next
            % biggest ellipse
            
            stats(ind,:) = [];
            if isempty(stats)~=1
                [~, ind] = max(stats.Area);
            else
                flag = 1;
                ind = 0;
            end
        end
        j = j+1;
    end
else
    flag = 1;
  
end

%% Checking for flagging and whether an appropriate ellipse was found:

if ind~=0 && flag ~= 1
    ctr = stats.Centroid(ind,:);
    minor = stats.MinorAxisLength(ind);
    area = stats.Area(ind);
elseif flag == 1 && ind~=0
    minor = NaN;
    ctr = [prevCenter(1) prevCenter(2)];
    area = NaN;
elseif flag ==1 && ind == 0
    minor = 0;
    ctr = [prevCenter(1) prevCenter(2)];
    area = 0;
end

