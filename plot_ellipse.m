function [] = plot_ellipse(stats,ind,frame,contour,trackYN)

% This function plots ellipses, to be used in the eye tracking algorithm.
% This uses information from stats table and plots an ellipse on a figure
% 
% Function inputs:
% stats     - table with relevant ellipses parameters (area, location etc)
% ind       - index of relevant ellipse within stats table
% frame     - current frame (image matrix)
% contour   - current detected contour
% trackYN   - binary marker to determine if the ellipse found is valid (1)
% 
% The function has no outputs.
%
% © Guy Tsror, McGill Universty, 2018

%%

if trackYN == 1
    
    % in this case, ellipse was detected ok
    
    phi = linspace(0,2*pi,50);

    % grabbing center location (1st row, two elemetns)
    x0 = stats.Centroid(ind,1);
    y0 = stats.Centroid(ind,2);
    
    % grabbing the major and minor axes size (taken as the maxiaml from the
    % list)
    a = max(stats.MajorAxisLength)/2;
    b = max(stats.MinorAxisLength)/2;
    
    % grabbing the angle of the elliptical tilt
    theta = pi*stats.Orientation(ind)/180;
    R = [cos(theta) sin(theta)
        -sin(theta) cos(theta)];

    % calculating the new elipse
    
    xy = [a*cos(phi); b*sin(phi)];
    xy = R*xy;
    x = xy(1,:) + x0;
    y = xy(2,:) + y0;

    
    imshow(frame); 
    hold on;
    visboundaries(contour,'Color','r','LineWidth',1);
    plot(x,y,'c','linewidth',0.75);
    
else
    % in this case we only plot the contour, without the ellipse
    
	imshow(frame); 
    hold on;
    visboundaries(contour,'Color','r','LineWidth',1);
end
