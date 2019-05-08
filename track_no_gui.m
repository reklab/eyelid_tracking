% This code can be used and manipulated to load the process without using
% the GUI/exe file
%
% Instead, create or edit parameter files (init_param.csv) in advance with all the required
% parameters, and load using the provided function, to feed into the
% tracking function, eyelid_tracking_gui.

param_file_path = 'init_param.csv';

param_in = readtable(param_file_path);

roi_is = str2double(param_in{1,2});
fps = str2double(param_in{2,2});
vid_yn = str2double(param_in{3,2});
color = param_in{4,2};
suffix = param_in{5,2};
right_left = str2double(param_in{6,2});
fname = param_in{7,2};

eyelid_tracking_gui(roi_is,fps,vid_yn,color{1},suffix{1},right_left,fname{1})