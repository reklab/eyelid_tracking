function [] = profile_eyelid_parallel()

% When using the parallel option, the user will have to pick the ROI. Later
% on, we can introduce a case where it's not essential.
% nPars     - number of parallels we aim to run with. This will depend on
% the signal structure, and should ideally not cause problems with signal
% division into equal parts.

%% Phase 0: Generating a struct file with info on the folder. Essential in the first run of a vid
[frames, sortedStruct] = sortJPEGs();

%% Phase 1 - loading .tiff files with/without conversion to jpeg

% if no conversion is needed - please input conversion == 0; otherwise, 1.

answer{1} = '2';
fps = 500;

while answer{1} ~= '0' && answer{1} ~= '1'
    prompt = {'Conversion from tiff to jpeg required? Enter 0/1',...
        'ROI already set? Enter 1/0','Output file name'...
        'Right or left eye? 1-R, 2-L'...
        'Save video? Enter 1/0'...
        'GS or RGB?'...
        'jpeg, jpg, JPEG or JPG?'};
    title = 'File Loading';
    dims = [1 35];
    definput = {'0','0','your_file','1','0','RGB','jpeg'};
    answer = inputdlg(prompt,title,dims,definput);
    filename2 = answer{3};
    RightLeft = str2double(answer{4});
    vidYN = str2double(answer{5});
    color = answer{6};
    suffix = answer{7};
    roi_Need = answer{2};
end

% loading the files:

if answer{1} == '0'
    % in this case, files are already in jpeg. User will be requested to
    % pick folder containing jpeg files.
    
    folder = uigetdir('C:\','Select jpeg folder');
    frames = length(dir([folder '/*.' suffix]));
    load([folder '\files_struct.mat']);
    
elseif answer{1} == '1'
    % in this case conversion from tiff to jpeg is needed.
    
    [folder, frames, sortedStruct] = tiff2jpg();
end



gs = color;
%% Phase 1.5 - Dividing the signal to nPars partitions


prompt = {'How many partitions?'};
definput = {'1'};
title = 'Partition Initialization';
dims = [1 30];
answer = inputdlg(prompt,title,dims,definput);
nPars = str2double(answer{1});


if nPars ~= 1
    partitionOK = 0;
    while partitionOK ~= 1
        
        % In this case, we have more than a single processor at a time. First
        % step of the process is to allow snapshot of the first frames of each
        % partition.
        % Once the user thinks the partition is OK, we change partitionOK
        % from 0 to 1
        
        lag_length = floor(frames/nPars);
        % defining the starting points for each lag:
        fr_start = ones(1,nPars);
        for i = 2:nPars
            %fr_start(i) = fr_start(i-1)+lag_length-1;
            fr_start(i) = fr_start(i-1)+lag_length; 
            figure(i-1)
            imshow(imread([folder '\' sortedStruct(fr_start(i)).name(1:end-(length(suffix)+1)) '.' suffix]))
        end
        
        pause(5);
        
        prompt = {'Is the partition OK?'};
        definput = {'1'};
        title = 'Partition Validation';
        dims = [1 30];
        answer = inputdlg(prompt,title,dims,definput);
        partitionOK = str2double(answer{1});
        close all;
        
        if partitionOK == 0
            % re partition:
            prompt = {'How many partitions?'};
            definput = {'1'};
            title = 'Partition Re-initialization';
            dims = [1 30];
            answer = inputdlg(prompt,title,dims,definput);
            nPars = str2double(answer{1});
            
        end
    end
end


%% Phase 2 - Processing of first frame for each partitions, followed by the tracking of the eye

if nPars ~= 1
    % This case will include parallel computing
    % In this case, no ROI was defined in the past. User will now define it
    
    % Loading first frame:
    frame1 = imread([folder '\' sortedStruct(1).name(1:end-(length(suffix)+1)) '.' suffix]);
    
    % User to crop ROI. Same ROI will be used for all frames in video
    
    [frROI, rect] = imcrop(frame1); % rect: [xmin,ymin,width,height]
    close all;
    imshow(frROI)
    [user_init, ~, ~] = roipoly();
    close all
    eyeSig = zeros(nPars,lag_length);
    areaSig = zeros(1,frames);
    ctrSigX = zeros(1,frames);
    ctrSigY = zeros(1,frames);
    skipLen = 140;
    full_blink_marker = zeros(nPars,lag_length);
    
    tic
    parfor i = 1:nPars
        
        %     frSk = -1; skipLen = 140;
        tmp = zeros(1, lag_length);
        tmp_blink = zeros(1, lag_length);
        % Phase 2.5 - Processing of first frame for each partitions
        % User to define the first area on first frame. This will be used in all
        % partitions to initialize their contour of reference.
        
        init_frame = imcrop(imread([folder '\' sortedStruct(fr_start(i)).name(1:end-(length(suffix)+1)) '.' suffix]),rect);
        [prevCenter,maxArea,prevMask,origAngle,HSVranges] = init_partition(init_frame,user_init,gs);
        
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
            
            frameIn = imread([folder '\' sortedStruct(fr_start(i)+fr-1).name(1:end-(length(suffix)+1)) '.' suffix]);
            frame = imcrop(frameIn,rect);
            %         clear frameIn
            
            %         if fr>2 && isnan(eyeSig(i,fr-2))==1
            if fr>2 && isnan(tmp(fr-2))==1
                iter = 30;
                [minorAxis, prevCenter, ~, prevMask, inBlink, isClosed] = contour_track(frame, maxArea, zeroMask, zeroCenter, origAngle, 0, inBlink, iter, zeroCenter, HSVranges, gs);
                iter = 15;
            else
                [minorAxis, prevCenter, ~, prevMask, inBlink, isClosed] = contour_track(frame, maxArea, prevMask, prevCenter, origAngle, 0, inBlink, iter, zeroCenter, HSVranges, gs);
                iter = 15;
            end
            
            % Dealing with complete blinks:
            
            if inBlink == 1 && isClosed == 1
                
                % in case both of these are flagged, our eye is entirely
                % closed and a skip ahead is required
                % The protocol in this case will be to mark the event, and skip
                % either 140 frames ahead, or to the end of the current
                % partition.
                
                tmp_blink(fr) = fr;
                tmp(fr) = -100; % setting a temporary value to clearly be irrelevant
                
                % determine size of skip ahead:
                if (fr_start(i)+lag_length-1-fr) < (skipLen+1)
                    % in this case, the gap between the current frame and the
                    % end of the current partition, is smaller than the usual
                    % skip length we use, so we skip to the end of the
                    % partition
                    fr = lag_length;
                else
                    fr = fr + skipLen;
                    
                end
                
                
                iter = 200;
                prevMask = zeroMask;
                inBlink = 0;
            end
            
            %         if frSk ~= fr - skipLen % if this is the case, it means that it's not right after a full blink process
            %             % Dealing with empty axes:
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
            %         end
            
            fr = fr + 2;
            
            if mod(fr,501)==0
                disp(['Frame number: ' num2str(fr) '/' num2str(frames)]);
            end
        end
        eyeSig(i,:) = tmp;
        full_blink_marker(i,:) = tmp_blink;
        
    end
    
elseif nPars == 1
    
    % in case we don't want parallel running (nPars == 1)
    if roi_Need == '0'
        
        % In this case, no ROI was defined in the past. User will now define it
        
        % Loading first frame:
        frame1 = imread([folder '\' sortedStruct(1).name(1:end-(length(suffix)+1)) '.' suffix]);
        
        % User to crop ROI. Same ROI will be used for all frames in video
        
        [frROI, rect] = imcrop(frame1); % rect: [xmin,ymin,width,height]
        close all;
        
        % User to define the first contour on the first frame:
        
        [prevCenter,maxArea,prevMask,origAngle,Xs,Ys,HSVranges] = eye_edge_gs(frROI,1,-1,-1,-1,gs);
        
        % Saving data for future use
        firstFrameInput = cell(3,2);
        firstFrameInput{1,1} = frROI;
        firstFrameInput{1,2} = rect;
        firstFrameInput{2,1} = Xs;
        firstFrameInput{2,2} = Ys;
        firstFrameInput{3,1} = prevMask;
        firstFrameInput{3,2} = HSVranges;
        
        % Saving the initialization file for the selected contour and ROI
        
        if RightLeft == 1
            % meaning, running on right eye
            save([filename2 '_init_R'], 'firstFrameInput')
        elseif RightLeft == 2
            save([filename2 '_init_L'], 'firstFrameInput')
        end
        
        % Setting baseline masks:
        
        zeroMask = prevMask;
        zeroCenter = prevCenter;
        
    else
        % In case ROI was already defined in the past, the user could load it
        % from an initiation file
        
        uiopen('*.mat');
        
        Xs = firstFrameInput{2,1};
        Ys = firstFrameInput{2,2};
        rect = firstFrameInput{1,2};
        zeroMask = firstFrameInput{3,1};
        %     HSVranges = firstFrameInput{3,2};
        [prevCenter,maxArea,~,origAngle,~,~,HSVranges] = eye_edge(firstFrameInput{1,1},0,Xs,Ys,zeroMask);
        prevMask = zeroMask;
        zeroCenter = prevCenter;
        
    end
    
    eyeSig = zeros(1,frames);
    areaSig = zeros(1,frames);
    ctrSigX = zeros(1,frames);
    ctrSigY = zeros(1,frames);
    i=1;
    inBlink = 0;
    iter = 15;
    fr = 1;   
    % Phase 3 - Active contour tracking
    
    if vidYN == 1
        
        % In case a video output is required, this portion of code will run.
        
        v = VideoWriter(filename2,'MPEG-4');
        v.FrameRate = 150;
        v.Quality = 100;
        open(v);
        
        while fr < frames-5
            
            % loading the next relevant frame:
            
            frameIn = imread([folder '\' sortedStruct(fr).name(1:end-(length(suffix)+1)) '.' suffix]);
            frame = imcrop(frameIn,rect);
            clear frameIn
            figure(1)
            
            % The next if statements is dealing with more than one NaN in a
            % row, by resetting the contour used as reference - instead of
            % using prevMask, it will use zeroMask, and instead 15 iterations,
            % it will use 30 iterations.
            
            if fr>2 && isnan(eyeSig(fr-2))==1
                % case more than a single NaN in a row
                iter = 30;
                [minorAxis, prevCenter, curArea, prevMask, inBlink, isClosed] = contour_track(frame, maxArea, zeroMask, zeroCenter, origAngle, 1, inBlink, iter, zeroCenter, HSVranges, gs);
                iter = 15;
            else
                [minorAxis, prevCenter, curArea, prevMask, inBlink, isClosed] = contour_track(frame, maxArea, prevMask, prevCenter, origAngle, 1, inBlink, iter, zeroCenter, HSVranges, gs);
                iter = 15;
            end
            
            
            % Next if statement deals with complete blinks. if both inBlink and
            % isClosed are marked as 1, it means that the eye is fully closed.
            % In this case, the process will skip ahead 140 frames (case
            % 500fps), and will run backwards to the point where it stopped. In
            % case the two variables are not 1, the code will continue.
            
            if inBlink == 1 && isClosed == 1
                
                curCenter = prevCenter;
                skipLen = 140; % this might need to change depending on fps
                tmpPrvMsk = zeroMask;
                tmpIter = 200;
                
                for frSk = (skipLen+fr):-2:fr
                    
                    frameInTmp = imread([folder '\' sortedStruct(frSk).name(1:end-(length(suffix)+1)) '.' suffix]);
                    frameTmp = imcrop(frameInTmp,rect);
                    clear frameInTmp
                    
                    [tmpMinAx, prevCenter, tmpCurArea, tmpPrvMsk, inBlink, ~] = contour_track(frameTmp, maxArea, tmpPrvMsk, prevCenter, origAngle, 1, inBlink, tmpIter, zeroCenter, HSVranges, gs);
                    
                    % Dealing with empty minor axes (no ellipse detected):
                    
                    if isempty(tmpMinAx) == 0
                        % meaning, there was an ellipse found (area non zero)
                        eyeSig(frSk) = tmpMinAx;
                        areaSig(frSk) = tmpCurArea;
                        ctrSigX(frSk) = prevCenter(1);
                        ctrSigY(frSk) = prevCenter(2);
                    else
                        % meaning, no ellipse was detected -> area is zero and eye
                        % is completley closed (axis = 0)
                        eyeSig(frSk) = 0;
                        areaSig(frSk) = 0;
                        ctrSigX(frSk) = prevCenter(1);
                        ctrSigY(frSk) = prevCenter(2);
                    end
                    
                    tmpIter = 15;
                    
                    % Visual Module:
                    xlabel(['Frame: ' num2str(frSk) '/' num2str(frames) ' frames']);
                    pause(0.000001)
                    disp(['Frame num: ' num2str(double(frSk)) ]);
                    F = getframe;
                    writeVideo(v,F.cdata);
                    
                end
                
                inBlink = 0;
                
                % Skipping frames from outer run:
                fr = fr + skipLen;
                iter = 200;
                prevMask = zeroMask;
                prevCenter = curCenter;
                clear frameTmp
                
            end
            
            % Dealing with empty minor axes (no ellipse detected):
            
            if isempty(minorAxis) == 0
                
                % meaning, there was an ellipse found (area non zero)
                eyeSig(fr) = minorAxis;
                areaSig(fr) = curArea;
                ctrSigX(fr) = prevCenter(1);
                ctrSigY(fr) = prevCenter(2);
                
            else
                
                % meaning, no ellipse was detected -> area is zero and eye
                % is completley closed (axis = 0)
                eyeSig(fr) = 0;
                areaSig(fr) = 0;
                ctrSigX(fr) = prevCenter(1);
                ctrSigY(fr) = prevCenter(2);
                
            end
            
            
            % Visual Module (plotting ellipse on figure, and saving video):
            xlabel(['Frame: ' num2str(fr) '/' num2str(frames) ' frames']);
            pause(0.000001)
            disp(['Frame num: ' num2str(double(fr))]);
            F = getframe;
            writeVideo(v,F.cdata);
            
            fr = fr + 2;
            
            % To update user on status, this will mark every 500 frames
            % processed.
            
            if mod(fr,501)==0
                disp(['Frame number: ' num2str(fr) '/' num2str(frames)]);
            end
        end
        close(v)
        
    else
        
        % this will run in case no video file is required as part of the
        % output. The code is essentially the same, excluding plotting parts.
        % There's no visual feedback in this case, except for the message every
        % 500 frames.
        
        while fr < frames-5
            
            % loading the next relevant frame
            
            frameIn = imread([folder '\' sortedStruct(fr).name(1:end-(length(suffix)+1)) '.' suffix]);
            frame = imcrop(frameIn,rect);
            clear frameIn
            
            if fr>2 && isnan(eyeSig(fr-2))==1
                iter = 30;
                [minorAxis, prevCenter, curArea, prevMask, inBlink, isClosed] = contour_track(frame, maxArea, zeroMask, zeroCenter, origAngle, 0, inBlink, iter, zeroCenter, HSVranges, gs);
                iter = 15;
            else
                [minorAxis, prevCenter, curArea, prevMask, inBlink, isClosed] = contour_track(frame, maxArea, prevMask, prevCenter, origAngle, 0, inBlink, iter, zeroCenter, HSVranges, gs);
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
                    
                    frameInTmp = imread([folder '\' sortedStruct(frSk).name(1:end-(length(suffix)+1)) '.' suffix]);
                    frameTmp = imcrop(frameInTmp,rect); % rect is xmin ymin width and height
                    clear frameInTmp
                    
                    [tmpMinAx, prevCenter, tmpCurArea, tmpPrvMsk, inBlink, ~] = contour_track(frameTmp, maxArea, tmpPrvMsk, prevCenter, origAngle, 0, inBlink, tmpIter, zeroCenter, HSVranges, gs);
                    
                    % Dealing with empty axes:
                    
                    if isempty(tmpMinAx) == 0
                        % meaning, there was an ellipse found (area non zero)
                        eyeSig(frSk) = tmpMinAx;
                        areaSig(frSk) = tmpCurArea;
                        ctrSigX(frSk) = prevCenter(1);
                        ctrSigY(frSk) = prevCenter(2);
                    else
                        % meaning, no ellipse was detected -> area is zero and eye
                        % is completley closed (axis = 0)
                        eyeSig(frSk) = 0;
                        areaSig(frSk) = 0;
                        ctrSigX(frSk) = prevCenter(1);
                        ctrSigY(frSk) = prevCenter(2);
                    end
                    tmpIter = 15;
                    
                end
                inBlink = 0;
                
                % Skipping frames from outer run:
                fr = fr + skipLen;
                iter = 200;
                prevMask = zeroMask;
                prevCenter = curCenter;
                clear frameTmp
                
            end
            
            
            % Dealing with empty axes:
            if isempty(minorAxis) == 0
                % meaning, there was an ellipse found (area non zero)
                eyeSig(fr) = minorAxis;
                areaSig(fr) = curArea;
                ctrSigX(fr) = prevCenter(1);
                ctrSigY(fr) = prevCenter(2);
            else
                % meaning, no ellipse was detected -> area is zero and eye
                % is completley closed (axis = 0)
                eyeSig(fr) = 0;
                areaSig(fr) = 0;
                ctrSigX(fr) = prevCenter(1);
                ctrSigY(fr) = prevCenter(2);
            end
            
            fr = fr + 2;
            
            if mod(fr,501)==0
                disp(['Frame number: ' num2str(fr) '/' num2str(frames)]);
            end
        end
    end
    
    
    
end
disp('Elapsed tracking time is: ')
toc

%% Reassign values to the original signal
if nPars ~= 1
    eyeSig_combined = zeros(1,frames);
    full_blink_start =[];
    for j = 1:nPars
        eyeSig_combined(fr_start(j):fr_start(j)+lag_length-1) = eyeSig(j,:);
        full_blink_start = [full_blink_start, find(full_blink_marker(j,:)~=0)+(lag_length*(j-1))];
    end
else
    eyeSig_combined = eyeSig;
end


%% Phase 3 - going back to full blinks processing:
if nPars ~= 1
    if isempty(full_blink_start)==0
        % in this case, there were full blinks
        
        % setting the initial contour once again since it's not available from
        % the parfor
        init_frame = imcrop(imread([folder '\' sortedStruct(fr_start(1)).name(1:end-(length(suffix)+1)) '.' suffix]),rect);
        [prevCenter,maxArea,zeroMask,origAngle,HSVranges] = init_partition(init_frame,user_init,gs);
        zeroCenter = prevCenter;
        for k = 1:length(full_blink_start)
            
            %         curCenter = prevCenter;
            skipLen = 140;
            tmpPrvMsk = zeroMask;
            tmpIter = 50;
            
            for frSk = full_blink_start(k)+skipLen:-2:full_blink_start(k)
                
                frameInTmp = imread([folder '\' sortedStruct(frSk).name(1:end-(length(suffix)+1)) '.' suffix]);
                frameTmp = imcrop(frameInTmp,rect); % rect is xmin ymin width and height
                clear frameInTmp
                
                [tmpMinAx, prevCenter, tmpCurArea, tmpPrvMsk, ~, ~] = contour_track(frameTmp, maxArea, tmpPrvMsk, prevCenter, origAngle, 0, 1, tmpIter, zeroCenter, HSVranges, gs);
                
                % Dealing with empty axes:
                
                if isempty(tmpMinAx) == 0
                    % meaning, there was an ellipse found (area non zero)
                    eyeSig_combined(frSk) = tmpMinAx;
                    %                     areaSig(frSk) = tmpCurArea;
                    %                     ctrSigX(frSk) = prevCenter(1);
                    %                     ctrSigY(frSk) = prevCenter(2);
                else
                    % meaning, no ellipse was detected -> area is zero and eye
                    % is completley closed (axis = 0)
                    eyeSig_combined(frSk) = 0;
                    %                     areaSig(frSk) = 0;
                    %                     ctrSigX(frSk) = prevCenter(1);
                    %                     ctrSigY(frSk) = prevCenter(2);
                end
                tmpIter = 15;
                disp(['Done with ' num2str((1-(frSk-full_blink_start(k))/skipLen)*100)...
                    '% of blink ' num2str(k) ' of ' num2str(length(full_blink_start)) '!'])
            end
        end
    else
        % no full blinks detected
        disp('No full blinks were detected');
    end
end

%% Phase 4 - Output post processing and export

% Converting NaNs into actual data

t = 1/fps:1/fps:frames/fps;
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