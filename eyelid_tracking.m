% Blink and eye-openness tracking ==== complete code

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

%% Phase 2 - Processing of first frame

if answer{2} == '0'
    
    % In this case, no ROI was defined in the past. User will now define it
    
    % Loading first frame:
    frame1 = imread([folder '\' sortedStruct(1).name(1:end-5) '.jpeg']);
    
    % User to crop ROI. Same ROI will be used for all frames in video
    
    [frROI, rect] = imcrop(frame1); % rect: [xmin,ymin,width,height]
    close all;
    
    % User to define the first contour on the first frame:
    
    [prevCenter,maxArea,prevMask,origAngle,Xs,Ys,HSVranges] = eye_edge(frROI,1,-1,-1,-1);
    
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

% Announcing the arrays to be used later for eye tracking

eyeSig = zeros(1,frames);
areaSig = zeros(1,frames);
ctrSigX = zeros(1,frames);
ctrSigY = zeros(1,frames);
i=1;
inBlink = 0;
iter = 15;
fr = 1;

%% Phase 3 - Active contour tracking

if vidYN == 1
    
    % In case a video output is required, this portion of code will run.
    
    v = VideoWriter(filename2,'MPEG-4');
    v.FrameRate = 150;
    v.Quality = 100;
    open(v);
    
    while fr < frames-5
        
        % loading the next relevant frame:
        
        frameIn = imread([folder '\' sortedStruct(fr).name(1:end-5) '.jpeg']);
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
            [minorAxis, prevCenter, curArea, prevMask, inBlink, isClosed] = contour_track(frame, maxArea, zeroMask, zeroCenter, origAngle, 1, inBlink, iter, zeroCenter, HSVranges);
            iter = 15;
        else
            [minorAxis, prevCenter, curArea, prevMask, inBlink, isClosed] = contour_track(frame, maxArea, prevMask, prevCenter, origAngle, 1, inBlink, iter, zeroCenter, HSVranges);
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
                
                frameInTmp = imread([folder '\' sortedStruct(frSk).name(1:end-5) '.jpeg']);
                frameTmp = imcrop(frameInTmp,rect); 
                clear frameInTmp
                
                [tmpMinAx, prevCenter, tmpCurArea, tmpPrvMsk, inBlink, ~] = contour_track(frameTmp, maxArea, tmpPrvMsk, prevCenter, origAngle, 1, inBlink, tmpIter, zeroCenter, HSVranges);
                
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
        
        frameIn = imread([folder '\' sortedStruct(fr).name(1:end-5) '.jpeg']);
        frame = imcrop(frameIn,rect); 
        clear frameIn
    
        if fr>2 && isnan(eyeSig(fr-2))==1
            iter = 30;
            [minorAxis, prevCenter, curArea, prevMask, inBlink, isClosed] = contour_track(frame, maxArea, zeroMask, zeroCenter, origAngle, 0, inBlink, iter, zeroCenter, HSVranges);
            iter = 15;
        else
            [minorAxis, prevCenter, curArea, prevMask, inBlink, isClosed] = contour_track(frame, maxArea, prevMask, prevCenter, origAngle, 0, inBlink, iter, zeroCenter, HSVranges);
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
                clear frameInTmp
                
                [tmpMinAx, prevCenter, tmpCurArea, tmpPrvMsk, inBlink, ~] = contour_track(frameTmp, maxArea, tmpPrvMsk, prevCenter, origAngle, 0, inBlink, tmpIter, zeroCenter, HSVranges);
                
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

%% Phase 4 - Output post processing and export

% Converting NaNs into actual data

t = 1/fps:1/fps:(length(eyeSig)/fps);
tOdd = t(1:2:end-5);

eyeSig_final = naninterp(eyeSig(1:2:end-5));
areaSig_final = naninterp(areaSig(1:2:end-5));
ctrSig_final = cell(1,2);
ctrSig_final{1} = ctrSigX(1:2:end-5);
ctrSig_final{2} = ctrSigY(1:2:end-5);

signal_output_mat = cell(3,2);
signal_output_mat{1,1} = eyeSig_final;
signal_output_mat{1,2} = eyeSig;
signal_output_mat{2,1} = areaSig_final;
signal_output_mat{2,2} = areaSig;
signal_output_mat{3,1} = ctrSig_final;


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