function [tmp] = process_full_blink(prevCenter,skipLen,zeroMask,origAngle,zeroCenter,rect,fr,folder,sortedStruct,tmp,HSVranges,maxArea,inBlink)

% in case both of these are flagged, our eye is entirely
% closed and a skip ahead is required

% skipLen = 140;
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

tmp;
