function [focusedFrame] = relevant_eye(frame,HSVs)

% This function highlights pixels within a specific predefined range of HSV
% values, and returns a binary image, where relevant pixels are marked as 1
% and irrelevants are 0.
%
% The inputs for this function are:
% frame         - the frame evaluated (matrix)
% HSVs          - HSV means and stds extracted from the first frame
%
% © Guy Tsror, McGill University, 2018


frameHSV = rgb2hsv(frame);

hueImage = frameHSV(:, :, 1);
saturationImage = frameHSV(:, :, 2);
valueImage = frameHSV(:, :, 3);

% Defining the relevant pixels based on the pixel values extracted already:

relPixels = hueImage < HSVs(1,1)+2*HSVs(1,2) & saturationImage > HSVs(2,1)-2*HSVs(2,2)...
    & valueImage > HSVs(3,1)-2*HSVs(3,2) & valueImage < HSVs(3,1) + 0.5*HSVs(3,2);

% for 6400t series videos:
% relPixels = hueImage < 0.1 & hueImage < 0.9 & valueImage > 0.1 & valueImage < 0.7 & saturationImage > 0.75;

% for YDXJ series videos:
% relPixels = hueImage < 0.1 & hueImage < 0.9 & valueImage > 0.1 & valueImage < 0.7 & saturationImage > 0.5;

focusedFrame = frame;
focusedFrame(repmat(~relPixels,[1 1 3])) = 0;

