% ANALYSIS FILE - BLINKS IN INJURED AND HEALTHY RATS % 

%% Load data from both sides of face

[file_L, path] = uigetfile('*.mat','Please Select Left Eye');
load([path file_L]);
sig_L = signal_output_mat{1,1};
clear signal_output_mat

[file_R, path] = uigetfile('*.mat','Please Select Right Eye');
load([path file_R]);
sig_R = signal_output_mat{1,1};

%% Plotting both

fps = 500;
frames = signal_output_mat{3,1};

if iscell(frames) == 1 || isempty(frames)
    frames = 60000;
end

t = 1/fps:1/fps:frames/fps;
tOdd = t(1:2:end-5);

subplot 211
plot(tOdd, sig_L)
title('Left eye output signal');
xlabel('Time [s]'); ylabel('Minor axis length [px]');
grid on;

subplot 212
plot(tOdd, sig_R)
title('Right eye output signal');
xlabel('Time [s]'); ylabel('Minor axis length [px]');
grid on;

%% Conversion to nldat

left = nldat(sig_L', 'domainIncr',1/fps);
right = nldat(sig_R', 'domainIncr',1/fps);


%% Correlation inspection
figure()
[correl,lag] = correl_sigs(sig_L,sig_R,fps,1);

% possibly, delay could be inferred from the peak location

%% Frequency content inspection

spec_L = spect(left-mean(left));
% subplot 221
plot(spec_L); 
xlabel('Frequency [Hz]'); ylabel('Spectrum');
grid on;
hold on;
spec_R = spect(right-mean(right));
plot(spec_R);
title('Frequency Content');
legend('Left Spectrum','Right Spectrum');
xlim([0 10])

%% Filtering hf noises 

%% Consider running manual
