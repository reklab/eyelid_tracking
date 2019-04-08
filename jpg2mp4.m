function [] = jpg2mp4()

% This function creates videos files for folders containing .jpg images,
% and a sortedStruct MATLAB struct file, with information regarding the
% right order of files in the video.



folder = uigetdir('D:\Guy\Dropbox (NRP)\Diego_Guy\crush_experiement\2019_01_14\');

noStruct=0;
if noStruct == 1
    % if there's a need to sort the files first, run this:
    [frames, sortedStruct] = sortJPEGs2(folder, 'jpg');
    frames = length(dir([folder '/*.jpg']));
else
    % otherwise, load the filesstruct from file:
    load([folder '\files_struct.mat']);
end

outname = inputdlg('Please enter filename, without file extension');
v = VideoWriter(outname{1},'MPEG-4');
v.FrameRate = 150;
v.Quality = 100;
open(v);
fr=1;
tic
while fr < frames-1
    
    % loading the next relevant frame
    frameIn = imread([folder '\' sortedStruct(fr).name(1:end-4) '.jpg']);
    writeVideo(v,frameIn);
    fr = fr + 1;
    if mod(fr,500)==0
        disp(['Processed ' num2str(fr) ' frames']);
    end
    
end

close(v)
toc