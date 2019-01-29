function [] = mat2csv()

% This function loads a .mat file that was the output of a previous version
% of Blink Tracking using active contour, and converts it to .csv to load
% in Python for comparison purposes with ML based outputs.
% No inputs or outputs are required.
%
% Guy Tsror, January 2019

[in_file,~] = uigetfile;
load(in_file);
outname = in_file(1:end-4);
csvwrite([outname '.csv'],signal_output_mat{1,1}')

