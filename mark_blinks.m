function [nBlinks, blink_inds] = mark_blinks(tt,sig,plt)

% This function detects blink locations on the output signal, and returns
% the number of blinks the algorithm detected, and the locations of the
% blink peaks.
% tt represents a time series vector, that is only used for plotting, and
% could be zeros if plotting is not required.
% sig - the eyelid tracking output signal
% plt - a binary 1/0 to indicate if plotting is required
%
% The function works as follows: inspecting the signals's histogram, it
% finds a point beyond the tail of the histogram (defined by the 10th bin
% with 0 values in it). This point is the threshold for blinks. Any peaks
% detected beyond this point, with minimal peak distance of 5 time-units
% away, are considered blinks.
%
% Copyrights Guy Tsror, McGill University, 2018

flip_sig = -1*sig;
nbins = 500;

% finding the histogram counts for the flipped signals
[N,edges] = histcounts(flip_sig,nbins);

% defining the threshold - taking the 10th empty bin's edge, and setting as
% the threshold 
inds = find(N==0);
threshold = edges(inds(10));

[pks,locs,~,~] = findpeaks(flip_sig,'MinPeakHeight'...
    ,threshold,'MinPeakDistance',5);

% Optional plotting
if plt == 1
    figure()
    plot(tt,flip_sig,'k'); 
    hold on;
    scatter(tt(locs),pks,'r','*')
    xlabel('Time [sec]')
    ylabel('Minor Axis Length [px]');
    grid on;
    hold off;
end

nBlinks = length(pks);
blink_inds = locs;