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

%% OPTION: DEFINING FOR VALIDATION RUN

roi_is = 0;
fps = 500;
vid_yn = 1;
color = 'RGB';
suffix = 'jpg';
right_left=1;
% fname = 'J7A1R';
%fname = 'J17A2R';
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

begin_time = 61;%19
end_time = 63.5;%24

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

validation_output_mat = cell(4,1);
validation_output_mat{1} = eyeSigVal;
validation_output_mat{2} = fr_range;
% validation_output_mat{3} = ctrSigX;
% validation_output_mat{4} = ctrSigY;
% validation_output_mat{5} = angleSig;
% validation_output_mat{6} = i;
validation_output_mat{3} = fname;
validation_output_mat{4} = find(eyeSigVal~=0);

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
rel_frms = validation_output_mat{4};

t = 1/fps:2/fps:2*length(signal_output_mat{1,1})/fps;
t_sig = t(fr_range_sig(1):fr_range_sig(2));
t = 1/fps:1/fps:2*length(signal_output_mat{1,1})/fps;
t_val = t(fr_range(1):length(validation_output_mat{1}));

eyeSig = signal_output_mat{1,1}(fr_range_sig(1):fr_range_sig(2));
eyeSigVal = validation_output_mat{1};%(fr_range(1):fr_range(2));

plot(t_sig,eyeSig);hold on;
scatter(t_val(1:end),eyeSigVal(fr_range(1):length(eyeSigVal)),'.');
hold off
ylim([1, [max([eyeSigVal, eyeSig])+1]]);
xlim([min(t_val),max(t_val)]);
grid on;
title(['DLC output vs. manual validtion', fname])
xlabel('Time [sec]'); ylabel('Eye width [pixels]');

%% determining stats NEW:
eyeSigVal_rel = eyeSigVal(rel_frms);
eyeSig_rel = signal_output_mat{1,1};
eyeSig_rel = eyeSig_rel(ceil(rel_frms/2));

eyeSig_rel = eyeSig_rel-mean(eyeSig_rel);
eyeSigVal_rel = eyeSigVal_rel-mean(eyeSigVal_rel);

rmse = sqrt(sum((eyeSig_rel(:)-eyeSigVal_rel(:)).^2)/numel(eyeSig_rel));
mdl = fitlm(eyeSig_rel,eyeSigVal_rel);
r2 = mdl.Rsquared.Ordinary;

% IRFing
x = nldat(eyeSig_rel');
x.domainIncr = 1/fps;
v = nldat(eyeSigVal_rel');
v.domainIncr = 1/fps;


% VAFing
vafx = cell(1,200); j=0;
for ii = 5:5:1000
    j = j+1;
    irf2= irf(cat(2,v,x),'nLags',ii,'nSides',2);
    x_pred = nlsim(irf2,v);
    vafx{j} = vaf(x_pred,x);
    disp(['Finished ' num2str(j) ' runs']);
end
for i=1:200
    VAFsig(i) = vafx{i}.dataSet;
end
[~, lagind] = max(VAFsig);
ii = 5:5:1000;
nLags = ii(lagind);
%cat(2,input,output)
irff= irf(cat(2,v,x),'nLags',nLags,'nSides',2);

ii = 5:5:1000;
plot(ii,VAFsig);
grid on;
xlabel('Number of lags');
ylabel('VAF [%]');
title('Variance Accounted For');
