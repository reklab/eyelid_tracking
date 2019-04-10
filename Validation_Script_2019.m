% Validation Script
jpg=1;

%% Finding the correct files

if jpg == 1
    % files for the video were already converted; user requested to pick
    % first file
    
    folder = uigetdir('D:\Guy\Dropbox (NRP)\Diego_Guy\New videos\');
    frames = length(dir([folder '/*.jpg']));
%     load([folder '\files_struct.mat']);
elseif jpg == 0
    % conversion from tiff to jpeg is needed
    [~, frames, sortedStruct] = tiff2jpg();
end

% filename2 = 'march_8_animal_1_video_3';
% filename2 = 'animal_3_video_2';
% filename2 = 'animal_1_video_1b';
% filename2 = ''

% lrb = 2;
% fps = 250;

% %% Extraction of Data (including start coordinates)
%
% load animal_3_video_2ROI_R
%
% % data = cell(1);
% % [data{1}] = split_face2(0,filename,path,1);
% % disp('Finished splitting and getting eye.')
% % [~,~,~,~,Xs,Ys,HSVRanges] = eye_Edge2(data{1}{1});
% InitXY = [Xs, Ys];
% Init_YDXJ122_L = cell(1,3);
% Init_YDXJ122_L{1} = data;
% Init_YDXJ122_L{2} = InitXY;
% Init_YDXJ122_L{3} = HSVRanges;
% save([filename '_L_Sqr'], 'Init_YDXJ122_L')

%% OPTION 1: OLD - do not use - lOADING for validation run
load march_8_animal_1_video_3_init_L
load animal_3_video_2_init_L
load animal_1_video_1b_init_L


prevX = firstFrameInput{2,1};
prevY = firstFrameInput{2,2};
HSVrange = firstFrameInput{3,2};
rect = firstFrameInput{1,2};
eyeSig = zeros(1,frames);
areaSig = zeros(1,frames);
ctrSigX = zeros(1,frames);
ctrSigY = zeros(1,frames);
angleSig = zeros(1,frames);

%% OPTION 2: DEFINING FOR VALIDATION RUN

roi_is = 0;
fps = 500;
vid_yn = 1;
color = 'RGB';
suffix = 'jpg';
right_left=1;
fname = 'J7A1R';
fname = 'F7A4R';


% folder = uigetdir('C:\','Select jpeg folder containing frames:');
frames = length(dir([folder '/*.' suffix]));

if exist([folder '\files_struct.mat'], 'file')
    
    % Struct file exists.  We can process frames:
    load([folder '\files_struct.mat']);
else
    % File does not exist, will be created now:
    disp('Sorting files to chronological order...');
    [frames, sortedStruct] = sortJPEGs2(folder, suffix);
end


% Loading first frame:
frame1 = imread([folder '\' sortedStruct(1).name(1:end-(length(suffix)+1)) '.' suffix]);

% User to crop ROI. Same ROI will be used for all frames in video
figure()
[frROI, rect] = imcrop(frame1); % rect: [xmin,ymin,width,height]
close all;

% User to define the first contour on the first frame:

[prevCenter,maxArea,prevMask,origAngle,Xs,Ys,HSVranges] = eye_edge_gs(frROI,1,-1,-1,-1,color);


% setting start frame and end frame:

begin_time = 61;
end_time = 62.5;

begin_fr = begin_time*fps;
end_fr = end_time*fps;

% Setting up variable
eyeSigVal = zeros(1,end_fr-begin_fr+1);

%% Validation run

if right_left == 1
    % meaning, running on right eye
    v = VideoWriter([fname '_R_Val_Run'],'MPEG-4');
elseif right_left == 2
    v = VideoWriter([fname '_L_Val_Run'],'MPEG-4');
end

v.FrameRate = 150;
v.Quality = 100;
open(v);
totfrstr = num2str(length(eyeSigVal));

i = begin_fr;

% frameIn = imread([folder '\' sortedStruct(i).name(1:end-5) '.' suffix]);
% frame = imcrop(frameIn,rect); % rect is xmin ymin width and height
% clear frameIn
% imshow(frame);
% [~, prevX, prevY] = roipoly(frame);
prevX = Xs;
prevY = Ys;
close all


% for i = begin_fr:end_fr
while i < end_fr
% loading the next relevant frame
    frameIn = imread([folder '\' sortedStruct(i).name(1:end-4) '.' suffix]);
    frame = imcrop(frameIn,rect); % rect is xmin ymin width and height
    clear frameIn
    
    figure(1);
    [curX,curY,ctr,minor,area,angle,frms] = eye_Edge_val(frame,prevX,prevY);
    % if the code gets a bug sometime in the middle, it might be bc there
    % were 2 regions detected (unclear why yet). Just rerun the previous
    % line and continue as usual
    eyeSigVal(i) = minor;
%     areaSig(i) = area;
%     angleSig(i) = angle;
%     ctrSigX(i) = ctr(1);
%     ctrSigY(i) = ctr(2);
    prevX = curX;
    prevY = curY;
    pause(0.000001)
    F = getframe;
    writeVideo(v,F.cdata);
    disp(['Done with frame ' num2str(i)  ' out of ' num2str(end_fr)])
    i = i + frms;
end

close(v)

fr_range = [begin_fr, end_fr];

validation_output_mat = cell(3,1);
validation_output_mat{1} = eyeSigVal;
validation_output_mat{2} = fr_range;
% validation_output_mat{3} = ctrSigX;
% validation_output_mat{4} = ctrSigY;
% validation_output_mat{5} = angleSig;
% validation_output_mat{6} = i;
% validation_output_mat{7} = find(angleSig~=0);
validation_output_mat{3} = fname;

if right_left == 1
    % meaning, running on right eye
    save([fname '_R_ValOutput'], 'validation_output_mat')
elseif right_left == 2
    save([fname '_L_ValOutput'], 'validation_output_mat')
end
%% Validation vs. Actual
% Loading it all

%C:\Users\guyts\OneDrive\Important Docs\MSc\McGill\Thesis\Facial Reanimation\Thesis\Results\Recordings Used\Snakes\New Aparatus

disp('Please select .mat file containing the algorithm data');
uiopen('load');
disp('Please select .mat file containing the validation data');
uiopen('load');

%% NEW: 
fr_range = validation_output_mat{2};
fr_range_sig = fr_range/2;
fps = 500;

t = 1/fps:2/fps:2*length(signal_output_mat{1,1})/fps;
t_sig = t(fr_range_sig(1):fr_range_sig(2));
t = 1/fps:1/fps:2*length(signal_output_mat{1,1})/fps;
t_val = t(fr_range(1):fr_range(2));

eyeSig = signal_output_mat{1,1}(fr_range_sig(1):fr_range_sig(2));
eyeSigVal = validation_output_mat{1}(fr_range(1):fr_range(2));

plot(t_sig,eyeSig);hold on;
scatter(t_val(1:end-1),eyeSigVal);

%% OLD : In case it's part of the new recording system (TIFF + 500fps)

eyeSig = signal_output_mat{1,1};
eyeSigVal = validation_output_mat{1}(1:end-1);
areaSig = signal_output_mat{2,1};
areaSigVal = validation_output_mat{2}(1:end-1);
relFrms = validation_output_mat{7};
frames = length(eyeSigVal);
fps = 500;
t_sig = 1/fps:2/fps:2*length(eyeSig)/fps;
t_val = 1/fps:1/fps:(frames*1/fps);
% tval = validation_output_mat{7}/fps;
actualsVal = relFrms(end);
actualsSig = length(eyeSig);

% Zero padding actual signal to match lengths:
eyeSig0s = kron(eyeSig, [1 0]);
areaSig0s = kron(areaSig, [1 0]);
ctrX0s = kron(signal_output_mat{3,1}{1}, [1 0]);
ctrY0s = kron(signal_output_mat{3,1}{2}, [1 0]);

% equalizing both validation an automatic signals based on lengths
lendiff = length(eyeSigVal)-length(eyeSig0s);
eyeSigVal = eyeSigVal(1:end-lendiff);
areaSigVal = areaSigVal(1:end-lendiff);
ctrXvals = validation_output_mat{3}(1:frames-lendiff);
ctrYvals = validation_output_mat{4}(1:frames-lendiff);

% Finding center differences:
ctrDifXSig = ctrXvals - ctrX0s;
ctrDifYSig = ctrYvals - ctrY0s;

% AT THIS POINT THE SIGNALS AND VALIDATION WERE MATCHED ELEMENT-by-ELEMENT

%% cutting out endings if desired:
percentout = 10/100;
eyeSig0s = eyeSig0s(1:end-percentout*frames);
areaSig0s = areaSig0s(1:end-percentout*frames);
eyeSigVal = eyeSigVal(1:end-percentout*frames);
areaSigVal = areaSigVal(1:end-percentout*frames);
ctrDifXSig = ctrDifXSig(1:end-percentout*frames);
ctrDifYSig = ctrDifYSig(1:end-percentout*frames);
relFrms(relFrms>(1-percentout)*frames)=[];
%% We may now look at relevant frames only:
t2 = t_val(relFrms);

eyeSig_rel = eyeSig0s(relFrms);
areaSig_rel = areaSig0s(relFrms);
eyeSigVal_rel = eyeSigVal(relFrms);
areaSigVal_rel = areaSigVal(relFrms);
ctrDifXSig = ctrDifXSig(relFrms);
ctrDifYSig = ctrDifYSig(relFrms);

% % The relevant parts of the signals exclude the parts after the NaNs of the
% % validation signal
%
% areaSig = areaSig(1:actualsSig-1);
% areaSigVal = areaSigVal(1:actualsVal);
% eyeSig = eyeSig(1:actualsSig-1);
% eyeSigVal = eyeSigVal(1:actualsVal);
% t = t(1:actuals);

% to solve the 0s relevant frames problem: interpolating

%% In case it's part of the old system (240fps)

%% if it's not TIFF version (240fps):

eyeSig = signal_output_mat{1,1};
areaSig = signal_output_mat{2,1};
eyeSigVal = validation_output_mat{1};
areaSigVal = validation_output_mat{2}(1:end-1);
relFrms = validation_output_mat{7};
frames = length(eyeSigVal);
eyeSig_rel = eyeSig(relFrms);
areaSig_rel = areaSig(relFrms);
eyeSigVal_rel = eyeSigVal(relFrms);
areaSigVal_rel = areaSigVal(relFrms);

fps=240;
t = 1/fps:1/fps:(frames*1/fps);
t2 = t(relFrms);
%% if its red or edge:

eyeSig = eyeSig{1};
eyeSigVal = validation_output_mat{1};
relFrms = validation_output_mat{7};
frames = length(eyeSigVal);
eyeSig_rel = eyeSig(relFrms);
eyeSigVal_rel = eyeSigVal(relFrms);

fps=240;
t = 1/fps:1/fps:(frames*1/fps);
t2 = t(relFrms);

%% error calculations:

rmse_minor = sqrt(sum((eyeSig_rel(:)-eyeSigVal_rel(:)).^2)/numel(eyeSig_rel));
rmse_area = sqrt(sum((areaSig_rel(:)-areaSigVal_rel(:)).^2)/numel(areaSig_rel));


for i = 1:numel(areaSig_rel)
    err_minor(i) = (eyeSig_rel(i)-eyeSigVal_rel(i))/eyeSigVal_rel(i);
    err_area(i) = (areaSig_rel(i)-areaSigVal_rel(i))/areaSigVal_rel(i);
end

mean(err_minor)
std(err_minor)
mean(err_area)
std(err_area)
%% New analysis dashboard - no VAF
mdl = fitlm(eyeSig_rel,eyeSigVal_rel);
r2 = mdl.Rsquared.Ordinary;
[r_xy,lag] = correl_sigs(eyeSig_rel(:),eyeSigVal_rel(:),fps,0);

figure()

% Actual signals on top of each other:
subplot (3,2,[1 2])
plot(t2,eyeSig_rel,'color','b','linewidth',0.9);
hold on;
scatter(t2,eyeSigVal_rel,40,'.','r');
grid on;
xlim([0 t2(end)]);
ylim([2 1.1*max([max(eyeSig),max(eyeSigVal)])]);
ylabel('Pixels');
legend('Algorithm Output','Validation Data');
% set(gca,'Fontsize',14,'fontname','Times New Roman')
grid on; title('A) Output Signal and Validation Points');
hold off;

resid = eyeSig_rel-eyeSigVal_rel;
subplot (3,2,[3 4])
plot(t2,resid,'color','k','linewidth',0.7);
xlim([0 t2(end)]);
grid on; title('B) Residuals');
ylim([min(resid)-5 max(resid)+5]);
ylabel('Pixels');
xlabel('Time [sec]');

subplot 325
plot(lag, r_xy); grid on; %set(gca,'fontsize',16)
ylabel('Correlation'); xlabel('Lag [sec]'); xlim([min(lag) max(lag)]);
grid on; hold on;
% text(0.1,0.1,['R^2 = ' num2str(r2)])
title('C) Output/Validation cross-correlation');



%% Analysis -- old 1

rmse = sqrt(sum((eyeSig_rel(:)-eyeSigVal_rel(:)).^2)/numel(eyeSig_rel));
mdl = fitlm(eyeSig_rel,eyeSigVal_rel);
r2 = mdl.Rsquared.Ordinary;

subplot 211
plot(t2,eyeSig_rel,'color','b','linewidth',0.9);
hold on;
scatter(t2,eyeSigVal_rel,40,'.','r');
grid on;
xlim([0 t2(end)]);
ylim([2 1.1*max([max(eyeSig),max(eyeSigVal)])]);
ylabel('Minor Axis Length [Pixels]');
xlabel('Time [sec]');
title('Minor Axis Signal')
legend('Algorithm Output','Validation Data');
% set(gca,'Fontsize',14,'fontname','Times New Roman')
hold off;

% residuals:
resid = eyeSig_rel-eyeSigVal_rel;
subplot 212
plot(t2,resid,'color','k','linewidth',0.9);
grid on;
xlim([0 t2(end)]);
ylim([-30 30]);
ylabel('Residuals [Pixels]');
xlabel('Time [sec]');

subplot 212
plot(t2,areaSig_rel,'color','b','linewidth',0.9);
hold on;
scatter(t2,areaSigVal_rel,40,'.','r');
grid on;
xlim([0 t2(end)]);
ylim([200 1.1*max([max(areaSig),max(areaSigVal)])]);
ylabel('Eye Area [Pixels]');
xlabel('Time [sec]');
title('Eye Area Signals');
legend('Algorithm Output','Validation Data');
hold off;

subplot 313
scatter(t2,ctrDifXSig,25,'d','c');
hold on; grid on;
scatter(t2,ctrDifYSig,25,'d','m');
xlabel('Time [sec]');
ylabel('Difference [Pixels]')
legend('X Axis','Y Axis');
xlim([0 t2(end)]);
title('Center Coordinate Differences');

%% Filtering and processing pre analysis

%% Median filter to the algorithm signal
eyeSig_filt_M = medfilt1(eyeSig_rel,5);
plot(t_sig,eyeSig); hold on;
plot(t2,eyeSig_rel);
plot(t2,eyeSig_filt_M);
legend('Original','Relevant','Relevant Filtered')
%% Low pass filtering

d = fdesign.lowpass('Fp,Fst,Ap,Ast',0.1,0.2,0.1,40);
lpf = design(d,'equiripple');
fvtool(lpf)
eyeSig_filt_LP = filter(lpf,eyeSig);
plot(eyeSig); hold on; plot(eyeSig_filt_LP);

% seems like there's a 19 frames lag
%% taking the relevant frames (padding 0s and taking rel)
eyeSig_filt0s = kron(eyeSig_filt_LP, [1 0]);
eyeSig_filt_rel = eyeSig_filt0s(relFrms);
%% Finding coherence between the two:

cohere = mscohere(eyeSig_rel,eyeSigVal_rel);
plot(cohere)
%% Analysis---old

% subplot 311
% plot(t_sig,eyeSig,'color','b','linewidth',0.9);
% hold on;
% scatter(t_val,eyeSigVal,40,'.','r');
% grid on;
% xlim([0 t(relFrms(end))]);
% ylim([2 1.1*max([max(eyeSig),max(eyeSigVal)])]);
% ylabel('Minor Axis Length [Pixels]');
% xlabel('Time [sec]');
% title('Minor Axis Signal')
% legend('Algorithm Output','Validation Data');
% % set(gca,'Fontsize',14,'fontname','Times New Roman')
% hold off;
%
% subplot 312
% plot(t_sig,areaSig,'color','b','linewidth',0.9);
% hold on;
% scatter(t_val,areaSigVal,40,'.','r');
% grid on;
% xlim([0 t(relFrms(end))]);
% ylim([200 1.1*max([max(areaSig),max(areaSigVal)])]);
% ylabel('Eye Area [Pixels]');
% xlabel('Time [sec]');
% title('Eye Area Signals');
% legend('Algorithm Output','Validation Data');
% hold off;
%
% subplot 313
% scatter(t2,ctrDifXSig,25,'d','c');
% hold on; grid on;
% scatter(t2,ctrDifYSig,25,'d','m');
% xlabel('Time [sec]');
% ylabel('Difference [Pixels]')
% legend('X Axis','Y Axis');
% xlim([0 t(relFrms(end))]);
% title('Center Coordinate Differences');


%% Accuracy and statistics analysis

% Interpolating the missing values from the validation signal
% eyeSigVal_interp = interp1(t2,eyeSigVal(relFrms),t_sig);
% areaSigVal_interp = interp1(t2,areaSigVal(relFrms),t_sig);
% Getting the data to be the same length as the validation data:
% areaSigRel = areaSig0s(relFrms);
% eyeSigRel = eyeSig0s(relFrms);
option =2 ;
% Minor axis analysis:
[r_minor_xy,r2_minor,irff_minor,VAF_minor] = stats_analysis(t2,eyeSig_rel,eyeSigVal_rel, fps,option);
disp(['VAF was: ' num2str(max(VAF_minor)) '%']);

[r_area_xy,r2_area,irff_area,VAF_area] = stats_analysis(t2,areaSig_rel,areaSigVal_rel, fps,option);
disp(['VAF was: ' num2str(max(VAF_area)) '%']);

[r_minor_xy,r2_minor,irff_minor,VAF_minor] = stats_analysis(t2(100:end),eyeSig_filt_rel(100:end),eyeSigVal_rel(100:end), fps);

% Area analysis:
% [r_area_xy,r2_area,irff_area,VAF_area] = stats_analysis(t,areaSig,areaSigVal(relFrms), fps);

%% Plotting area vs minor axis choice
% using 6400t1_2018_2, right

subplot 221
plot(t2,eyeSig_rel,'color','b','linewidth',0.9);
hold on;
scatter(t2,eyeSigVal_rel,40,'.','r');
grid on;
xlim([0 t2(end)]);
ylim([2 1.1*max([max(eyeSig),max(eyeSigVal)])]);
ylabel('Minor Axis Length [Pixels]');
xlabel('Time [sec]');
title('A) Minor Axis Signal')
legend('Algorithm Output','Validation Data');
hold off;

subplot 222
plot(t2,areaSig_rel,'color','b','linewidth',0.9);
hold on;
scatter(t2,areaSigVal_rel,40,'.','r');
grid on;
xlim([0 t2(end)]);
ylim([200 1.1*max([max(areaSig),max(areaSigVal)])]);
ylabel('Eye Area [Pixels]');
xlabel('Time [sec]');
title('B) Eye Area Signals');
legend('Algorithm Output','Validation Data');
hold off;

subplot 223
ii = 5:5:1000;
plot(ii,VAF_minor);
grid on;
ylabel('VAF [%]');
xlabel('Number of Lags');
title('C) Minor Axis VAF');

subplot 224
ii = 5:5:1000;
plot(ii,VAF_area);
grid on;
ylabel('VAF [%]');
xlabel('Number of Lags');
title('D) Eye Area VAF');
