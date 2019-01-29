function [] = jpg2mp4()

% This function creates videos files for folders containing .jpg images,
% and a sortedStruct MATLAB struct file, with information regarding the
% right order of files in the video.

folder = uigetdir('D:\Guy\Dropbox (NRP)\Diego_Guy\crush_experiement\2018_07_01\');
frames = length(dir([folder '/*.jpg']));
load([folder '\files_struct.mat']);

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