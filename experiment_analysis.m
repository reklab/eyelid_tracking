% ANALYSIS FILE - BLINKS IN INJURED AND HEALTHY RATS % 

%% Load data from both sides of face
clear all

[file_L, path] = uigetfile('*.mat','Please Select Left Eye');
load([path file_L]);
sig_L = signal_output_mat{1,1};
clear signal_output_mat

[file_R, path] = uigetfile('*.mat','Please Select Right Eye');
load([path file_R]);
sig_R = signal_output_mat{1,1};

%% eyelid movement figure:

fps = 500;
frames = signal_output_mat{3,1};
if iscell(frames) == 1 || isempty(frames)
    frames = 60000;
end
t = 1/fps:1/fps:frames/fps;
tOdd = t(1:2:end-5);

% eyes plot
uiwait(msgbox('In the next two figures, please select all blink peak points. You may double click to finish selection, or use backspace to remove last picked point.'));

figure(1)
plot(tOdd, sig_L,'color','blue');
xlabel('Time [sec]');
ylabel('Eye minor-axis length [px]');
grid on;
title('Left Eye Output - Select Blinks')
[t_blink_L, y_blink_L] = getpts;

figure(2)
plot(tOdd, sig_R,'color','red');
grid on;
xlabel('Time [sec]');
ylabel('Eye minor-axis length [px]');
title('Right Eye Output - Select Blinks')
[t_blink_R, y_blink_R] = getpts;

close all;

%% SHORT VERSION (Skip interim plots)

left = nldat(sig_L', 'domainIncr',1/fps);
right = nldat(sig_R', 'domainIncr',1/fps);
spec_L = spect(left-mean(left));
spec_R = spect(right-mean(right));
nLags = 200;
eye_irf = irf(cat(2,left,right),'nLags',nLags,'nSides',2);
%% LONG VERSION
%% combining plot
figure(1)
plot(tOdd, sig_L,'color','blue');
hold on;
plot(tOdd, sig_R,'color','red');
grid on;
xlabel('Time [sec]');
ylabel('Eye minor-axis length [px]');
hold on;
scatter(t_blink_L,y_blink_L,'o','MarkerEdgeColor','cyan')
scatter(t_blink_R,y_blink_R,'o','MarkerEdgeColor','magenta')
hold off;
legend('Left Eye','Right Eye')
%% Conversion to nldat
left = nldat(sig_L', 'domainIncr',1/fps);
right = nldat(sig_R', 'domainIncr',1/fps);
%% Correlation inspection
figure(2)
[correl,lag] = correl_sigs(sig_L,sig_R,fps,1);
% possibly, delay could be inferred from the peak location
%% Frequency content inspection
figure(3)
spec_L = spect(left-mean(left));
spec_R = spect(right-mean(right));
semilogx(spec_L); 
xlabel('Frequency [Hz]'); ylabel('Spectrum');
grid on;
hold on;
semilogx(spec_R);
title('Frequency Content, DC removed');
legend('Left Spectrum','Right Spectrum');
xlim([0 250])
%% histogram of both eyes, superimposed
figure(4)
histogram(sig_L,150,'FaceColor','blue','FaceAlpha',0.55,'EdgeAlpha',0,'Normalization','probability')
hold on;
histogram(sig_R,150,'FaceColor','Red','FaceAlpha',0.55,'EdgeAlpha',0,'Normalization','probability')
grid on;
xlabel('Eyelids Distance [px]'); ylabel('PDF');
legend('Left Eye','Right Eye')
hold off;
%% VAF calculations:
vaf_right = cell(1,200); j=0;
j=0;
for ii = 5:5:1000
    j = j+1;
    irf2= irf(cat(2,left',right'),'nLags',ii,'nSides',2);
    right_pred = nlsim(irf2,left);
    vaf_right{j} = vaf(right_pred,right);
    disp(['Finished ' num2str(j) ' runs']);
end
for i=1:200
    VAFsig(i) = vaf_right{i}.dataSet;
end

%% IRF per experiment:
[~, lagind] = max(VAFsig);
ii = 5:5:1000;
nLags = ii(lagind);
eye_irf = irf(cat(2,left,right),'nLags',nLags,'nSides',2);
figure(5)
plot(eye_irf); grid on;
ylabel('IRF');
title(['IRF Model, ' num2str(nLags) ' lags']);

%% Plotting all in a single exportable figure

close all
figure()

subplot(3,2,[1 2])
plot(tOdd, sig_L,'color','blue');
hold on;
plot(tOdd, sig_R,'color','red');
grid on;
xlabel('Time [sec]');
ylabel('Eye minor-axis length [px]');
hold on;
scatter(t_blink_L,y_blink_L,'o','MarkerEdgeColor','cyan')
scatter(t_blink_R,y_blink_R,'o','MarkerEdgeColor','magenta')
title('Output Signals, both eyes');
legend(['Left Eye, ', num2str(length(t_blink_L)), ' blinks'],...
    ['Right Eye, ', num2str(length(t_blink_R)), ' blinks'])
   
subplot(3,2,3)
[correl,lag] = correl_sigs(sig_L,sig_R,fps,1);
title('Correlation between eyes')
xlabel('Lag [sec]')
ylabel('Correlatiaon')
set(gca,'fontsize',10)

subplot(3,2,4)
semilogx(spec_L); 
xlabel('Frequency [Hz]'); ylabel('Spectrum');
grid on;
hold on;
semilogx(spec_R);
title('Frequency Content, DC removed');
legend('Left Spectrum','Right Spectrum');
xlim([0 250])

subplot(3,2,5)
histogram(sig_L,150,'FaceColor','blue','FaceAlpha',0.55,'EdgeAlpha',0,'Normalization','probability')
hold on;
histogram(sig_R,150,'FaceColor','Red','FaceAlpha',0.55,'EdgeAlpha',0,'Normalization','probability')
grid on;
xlabel('Eyelids Distance [px]'); ylabel('PDF');
legend('Left Eye','Right Eye')
title('PDF of both eyes')
hold off;

subplot(3,2,6)
plot(ii,VAFsig);
grid on;
xlabel('Number of lags');
ylabel('VAF [%]');
title('Variance Accounted For');

final_fig = gcf();

%% Export all:

% Exporting the figure to jpg and fig:
saveas(final_fig,[file_L(1:19) '_fig.fig']);
saveas(final_fig,[file_L(1:19) '_fig.jpg']);

% Exporting the blinks detected:
save([file_L(1:19) '_blinks'], 't_blink_L', 'y_blink_L', 't_blink_R', 'y_blink_R')

close all
