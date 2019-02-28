%% Process begins with checking for a sortedstruct file in the folder.

if exist([folder '\files_struct.mat'], 'file')
  % Struct file exists.  We can process frames:
else
  % File does not exist.
  warningMessage = sprintf('Warning: file does not exist:\n%s', fullFileName);
  uiwait(msgbox(warningMessage));
end


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
    if exist([folder '\files_struct.mat'], 'file')
        
        % Struct file exists.  We can process frames:
        load([folder '\files_struct.mat']);
    else
        % File does not exist.
        warningMessage = sprintf('Warning: file does not exist:\n%s', fullFileName);
        uiwait(msgbox(warningMessage));
    end
    
elseif answer{1} == '1'
    % in this case conversion from tiff to jpeg is needed.
    
    [folder, frames, sortedStruct] = tiff2jpg();
end



gs = color;