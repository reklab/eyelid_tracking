function [] = mat2csv()

% This function loads a .mat file that was the output of a previous version
% of Blink Tracking using active contour, and converts it to .csv to load
% in Python for comparison purposes with ML based outputs.
% The function interpolates the MATLAB output file, since it was
% downsampled in the process of tracking.
% No inputs or outputs are required.
%
% Guy Tsror, January 2019

[in_file,~] = uigetfile;
load(in_file);
outname = in_file(1:end-4);

val_yn = (contains(outname,'Val') || contains(outname,'val'));

if val_yn == 0
    % in this case, it's an output signal, rather than validation
    
    upSamp = upsample(signal_output_mat{1,1},2);
    x = 1:2:length(upSamp);
    xq = 1:1:length(upSamp)+1;
    vq = interp1(x,upSamp(x),xq);
    
else
    
    v = validation_output_mat{1,1};
    x = find(v~=0);
    xq = 1:1:length(v);
    vq = interp1(x,v(x),xq);
    
end

csvwrite([outname '.csv'],vq')
