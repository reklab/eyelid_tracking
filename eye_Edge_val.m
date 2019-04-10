function [curX,curY,ctr,minor,area,angle,frms] = eye_Edge_val(frame,prevX,prevY)

% This function is used in the initialization process of the eye tracking
% using edge detection. 
% It lets the user pick the eye area from the first frame of the videothat
% will be used as the mask for later frames.


% if i == 1
%     imshow(frame);
%     [curPoly, curX, curY] = roipoly();
%     set(gcf,'Units','Normalized','OuterPosition',[0.1,0.1,0.75,0.75]);
%
% else
imshow(frame);
prevPoly = impoly(gca,[prevX, prevY]);
set(gcf,'Units','Normalized','OuterPosition',[0.1,0.1,0.75,0.75]);
frms = button_press();
%     pause()
%     set(gcf, 'WindowButtonDownFcn', @double_click_fcn);
%     function double_click_fcn(hSource, ~)
curPolyCoor = getPosition(prevPoly);
[curPoly, curX, curY] = roipoly(frame,curPolyCoor(:,1),curPolyCoor(:,2));
    
    
% end

% Extracting the info from the current eye position
stats = regionprops('table',curPoly,'centroid','area','orientation','MinorAxisLength');

ctr = [stats.Centroid(1), stats.Centroid(2)];
angle = stats.Orientation;
area = stats.Area;
minor = stats.MinorAxisLength;