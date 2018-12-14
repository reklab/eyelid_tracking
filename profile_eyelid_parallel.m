function [] = profile_eyelid_parallel(nPars)

% When using the parallel option, the user will have to pick the ROI. Later
% on, we can introduce a case where it's not essential. 
% nPars     - number of parallels we aim to run with. This will depend on
% the signal structure, and should ideally not cause problems with signal
% division into equal parts. 


%% Phase 1 - loading .tiff files with/without conversion to jpeg

% if no conversion is needed - please input conversion == 0; otherwise, 1.

answer{1} = '2';
fps = 500;

while answer{1} ~= '0' && answer{1} ~= '1'
    prompt = {'Conversion from tiff to jpeg required? Enter 0/1',...
        'ROI already set? Enter 1/0','Output file name'...
        'Right or left eye? 1-R, 2-L'...
        'Save video? Enter 1/0'};
    title = 'File Loading';
    dims = [1 35];
    definput = {'0','0','your_file','1','0'};
    answer = inputdlg(prompt,title,dims,definput);
    filename2 = answer{3};
    RightLeft = str2double(answer{4});
    vidYN = str2double(answer{5});
end

% loading the files:

if answer{1} == '0'
    % in this case, files are already in jpeg. User will be requested to
    % pick folder containing jpeg files.
    
    folder = uigetdir('C:\','Select jpeg folder');
    frames = length(dir([folder '/*.jpeg']));
    load([folder '\files_struct.mat']);
    
elseif answer{1} == '1'
    % in this case conversion from tiff to jpeg is needed.
    
    [folder, frames, sortedStruct] = tiff2jpg();
end


%% Phase 1.5 - Dividing the signal to nPars partitions

disp('Dont forget to define number of Par-fors!');

lag_length = floor(frames/nPars);
% defining the starting points for each lag:
fr_start = ones(1,nPars);
for i = 2:nPars
    fr_start(i) = fr_start(i-1)+lag_length;
end
    

%% Phase 2 - Initializing ROI for the entire video (like before)

% if answer{2} == '0'

% In this case, no ROI was defined in the past. User will now define it

% Loading first frame:
frame1 = imread([folder '\' sortedStruct(1).name(1:end-5) '.jpeg']);

% User to crop ROI. Same ROI will be used for all frames in video

[frROI, rect] = imcrop(frame1); % rect: [xmin,ymin,width,height]
close all;

%% Phase 2.5 - Processing of first frame for each partitions


imshow(frROI)
[user_init, ~, ~] = roipoly();
close all
 
eyeSig = zeros(nPars,lag_length);
areaSig = zeros(1,frames);
ctrSigX = zeros(1,frames);
ctrSigY = zeros(1,frames);

tic
parfor i = 1:nPars
    
    frSk = -1; skipLen = 0;
    tmp = zeros(1, lag_length);
    % Phase 2.5 - Processing of first frame for each partitions    
    % User to define the first area on first frame. This will be used in all
    % partitions to initialize their contour of reference.
    
    init_frame = imcrop(imread([folder '\' sortedStruct(fr_start(i)).name(1:end-5) '.jpeg']),rect);
    [prevCenter,maxArea,prevMask,origAngle,HSVranges] = init_partition(init_frame,user_init);
    
    % Setting baseline masks:

    zeroMask = prevMask;
    zeroCenter = prevCenter;

    % Announcing the arrays to be used later for eye tracking

    inBlink = 0;
    iter = 15;

    % next section will be responsible for normally running active contour
    % detection, but limited to the partition its running on.
%     fr = fr_start(i);
    fr = 1;
    
%     while fr < fr_start(i)+lag_length-1 % Used to be -5// should verify ok
    while fr < lag_length % Used to be -5// should verify ok
        % loading the next relevant frame
        
        frameIn = imread([folder '\' sortedStruct(fr_start(i)+fr-1).name(1:end-5) '.jpeg']);
        frame = imcrop(frameIn,rect); 
%         clear frameIn
    
%         if fr>2 && isnan(eyeSig(i,fr-2))==1
        if fr>2 && isnan(tmp(fr-2))==1
            iter = 30;
            [minorAxis, prevCenter, ~, prevMask, inBlink, isClosed] = contour_track(frame, maxArea, zeroMask, zeroCenter, origAngle, 0, inBlink, iter, zeroCenter, HSVranges);
            iter = 15;
        else
            [minorAxis, prevCenter, ~, prevMask, inBlink, isClosed] = contour_track(frame, maxArea, prevMask, prevCenter, origAngle, 0, inBlink, iter, zeroCenter, HSVranges);
            iter = 15;
        end

        % Dealing with complete blinks:
        
        if inBlink == 1 && isClosed == 1
 
            % in case both of these are flagged, our eye is entirely
            % closed and a skip ahead is required
            
            curCenter = prevCenter;
            skipLen = 140;
            tmpPrvMsk = zeroMask;
            tmpIter = 200;
            
            for frSk = (skipLen+fr):-2:fr

                frameInTmp = imread([folder '\' sortedStruct(frSk).name(1:end-5) '.jpeg']);
                frameTmp = imcrop(frameInTmp,rect); % rect is xmin ymin width and height
%                 clear frameInTmp
                
                [tmpMinAx, prevCenter, tmpCurArea, tmpPrvMsk, inBlink, ~] = contour_track(frameTmp, maxArea, tmpPrvMsk, prevCenter, origAngle, 0, inBlink, tmpIter, zeroCenter, HSVranges);
                
                % Dealing with empty axes:
                
                if isempty(tmpMinAx) == 0
                    % meaning, there was an ellipse found (area non zero)
%                     eyeSig(i,frSk) = tmpMinAx;
                      tmp(frSk) = tmpMinAx;
%                     areaSig(frSk) = tmpCurArea;
%                     ctrSigX(frSk) = prevCenter(1);
%                     ctrSigY(frSk) = prevCenter(2);
                else
                    % meaning, no ellipse was detected -> area is zero and eye
                    % is completley closed (axis = 0)
%                     eyeSig(i,frSk) = 0;
                      tmp(frSk) = 0;
%                     areaSig(frSk) = 0;                    
%                     ctrSigX(frSk) = prevCenter(1);
%                     ctrSigY(frSk) = prevCenter(2);
                end
                tmpIter = 15; 
                
            end
            inBlink = 0;
            
            % Skipping frames from outer run:
            fr = fr + skipLen;
            iter = 200;
            prevMask = zeroMask;
            prevCenter = curCenter;
            %clear frameTmp
%             
        end        

        
        if frSk ~= fr - skipLen % if this is the case, it means that it's not right after a full blink process
            % Dealing with empty axes:
            if isempty(minorAxis) == 0
                % meaning, there was an ellipse found (area non zero)
                %             eyeSig(i,fr) = minorAxis;
                tmp(fr) = minorAxis;
                %             areaSig(fr) = curArea;
                %             ctrSigX(fr) = prevCenter(1);
                %             ctrSigY(fr) = prevCenter(2);
            else
                % meaning, no ellipse was detected -> area is zero and eye
                % is completley closed (axis = 0)
                %             eyeSig(i,fr) = 0;
                tmp(fr) = 0;
                %             areaSig(fr) = 0;
                %             ctrSigX(fr) = prevCenter(1);
                %             ctrSigY(fr) = prevCenter(2);
                
            end
        end
 
        fr = fr + 2;
        
        if mod(fr,501)==0
            disp(['Frame number: ' num2str(fr) '/' num2str(frames)]);
        end
    end
    eyeSig(i,:) = tmp;
end
disp('Elapsed tracking time is: ')
toc


%% Reassign values to the original signal
eyeSig_combined = zeros(1,frames);
for j = 1:nPars
    eyeSig_combined(fr_start(j):fr_start(j)+lag_length-1) = eyeSig(j,:);
end

%% Phase 4 - Output post processing and export

% Converting NaNs into actual data

t = 1/fps:1/fps:(length(eyeSig)/fps);
tOdd = t(1:2:end-5);

eyeSig_final = naninterp(eyeSig_combined(1:2:end-5));
areaSig_final = naninterp(areaSig(1:2:end-5));
ctrSig_final = cell(1,2);
ctrSig_final{1} = ctrSigX(1:2:end-5);
ctrSig_final{2} = ctrSigY(1:2:end-5);
[nBlinks, blink_inds] = mark_blinks(tOdd,eyeSig_final,1);

signal_output_mat = cell(4,2);
signal_output_mat{1,1} = eyeSig_final;
signal_output_mat{1,2} = eyeSig;
signal_output_mat{2,1} = areaSig_final;
signal_output_mat{2,2} = areaSig;
signal_output_mat{3,1} = ctrSig_final;
signal_output_mat{4,1} = nBlinks;
signal_output_mat{4,2} = blink_inds;

if RightLeft == 1
    save([filename2 '_R_SigOutput'], 'signal_output_mat')
elseif RightLeft == 2
    save([filename2 '_L_SigOutput'], 'signal_output_mat')
end


if RightLeft == 1
    disp('Finished running blink tracking on right eye only.')
elseif RightLeft == 2
    disp('Finished running blink tracking on left eye only.')
end