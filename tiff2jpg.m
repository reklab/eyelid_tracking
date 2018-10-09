function [folderout, i, sortedStruct] = tiff2jpg()

% this function converts a stack of tiff files into .jpeg files from a
% selcted directory.No input or output are needed.
% User needs to select the directory containing the tiff files.
% User needs to make sure a folder with the same name exists in the parent
% directory, with the same name but with a suffix "_jpegs"

%% Getting the required path and filename:

% folder = uigetdir('D:\Guy\Dropbox (NRP)\Diego_Guy\New videos\3-9-2018\animal_1\video_1');
folder = uigetdir('C:\');
folderout = [folder '_jpegs'];
all_files = dir([folder '/*.tiff']);
file_prefix_list = zeros(length(all_files),1);

% indexing the files:

for i = 1:length(all_files)   
   tmpsplit = strsplit(all_files(i).name,'_');
   filenum = tmpsplit{4}(1:end-5);
   filenum_double = str2double(filenum);
   file_prefix_list(i) = filenum_double;
   all_files(i).bytes = file_prefix_list(i);  %using temporarily the 'bytes' field as index 
end

[sortedStruct] = nestedSortStruct(all_files, 'bytes');

% converting the files:

tic
for i = 1:length(sortedStruct)
    filename = sortedStruct(i).name;
    imwrite(imread([folder '\' filename]), fullfile(folderout, [filename(1:end-5) '.jpeg']))
    if mod(i,500) == 0
        disp('converted 500 frames');
    end
end
disp('Converting the video took: ')
toc

% saving indexing of the files into .mat file named sortedStruct
save([folderout '\files_struct.mat'], 'sortedStruct')
