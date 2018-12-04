function [nBlinks, blink_inds] = mark_blinks(tt,sig,plt,th_pct)

% This function detects blink locations on the output signal, and returns
% the number of blinks the algorithm detected, and the locations of the
% blink peaks.
% tt represents a time series vector, that is only used for plotting, and
% could be zeros if plotting is not required.
% sig - the eyelid tracking output signal
% plt - a binary 1/0 to indicate if plotting is required
% th_pct - indicator of the percentage off the median to threshold the
% eyelids for blinks. Default setting is 25%

th_pct = 25;
flip_sig = -1*sig;
mdn = median(flip_sig);
threshold = mdn-mdn/(100/th_pct);
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