% This file is used for analysis of all the results

[~,~,data] = xlsread('results-summary.csv');

animal_1_corr = [];
animal_2_corr = [];
animal_3_corr = [];
animal_4_corr = [];
animal_6_corr = [];

interest = 'CCC';

if interest == 'CCC'
    col = 5;
else
    col = 4;
end


for i = 2:20
    if data{i,2} == 1
        animal_1_corr = [animal_1_corr abs(data{i,col})];
    elseif data{i,2} == 2
        animal_2_corr = [animal_2_corr abs(data{i,col})];
    elseif data{i,2} == 3
        animal_3_corr = [animal_3_corr abs(data{i,col})];
    elseif data{i,2} == 4
        animal_4_corr = [animal_4_corr abs(data{i,col})];
    else
        animal_6_corr = [animal_6_corr abs(data{i,col})];
    end
end


% getting confidence interval for control animals:
data_control = [animal_1_corr(1),animal_2_corr(1),animal_3_corr, animal_4_corr, animal_6_corr];
SEM = std(data_control)/sqrt(length(data_control));% Standard Error
ts = tinv([0.025  0.975],length(data_control)-1);      % T-Score
CI = mean(data_control) + ts*SEM;                      % Confidence Intervals



day_post_injury = [0,2,7,10,15,21,30];


figure()
plot(day_post_injury, animal_1_corr,'-o','linewidth',1.25,'color','blue')
hold on;
plot(day_post_injury(1:end-1), animal_2_corr,'-o','linewidth',1.25,'color','r')
grid on;
title('Animals left-right eye size correlation');

if interest == 'CCC'
    ylabel('Concordance Correlation Coefficient')
else
    ylabel('Pearson Correlation Coefficient')
end

xlabel('Post Operative Days');

% plotting the control and the CI:
x_axis=[day_post_injury(1),day_post_injury(end)];
x_plot = [x_axis, fliplr(x_axis)];
y_plot=[CI(1), CI(1), CI(2), CI(2)];

hold on;
plot(x_axis,[mean(data_control) mean(data_control)],'color','g','linewidth',2);
fill(x_plot, y_plot, 1,'facecolor', 'green', 'edgecolor', 'none', 'facealpha', 0.125);

legend('Animal 1','Animal 2','Mean of normals, n=6','CI')

%% Getting day by day for animal 2, both sides

% loading

clear all
load 2019_01_07_animal_2_L_SigOutput
day0L = signal_output_mat{1,1};
clear signal_output_mat
load 2019_01_07_animal_2_R_SigOutput
day0R = signal_output_mat{1,1};
clear signal_output_mat
load 2019_01_09_animal_2_L_SigOutput
day2L = signal_output_mat{1,1};
clear signal_output_mat
load 2019_01_09_animal_2_R_SigOutput
day2R = signal_output_mat{1,1};
clear signal_output_mat
load 2019_01_14_animal_2_L_SigOutput
day7L = signal_output_mat{1,1};
clear signal_output_mat
load 2019_01_14_animal_2_R_SigOutput
day7R = signal_output_mat{1,1};
clear signal_output_mat.
load 2019_01_17_animal_2_L_SigOutput
day10L = signal_output_mat{1,1};
clear signal_output_mat
load 2019_01_17_animal_2_R_SigOutput
day10R = signal_output_mat{1,1};
clear signal_output_mat
load 2019_01_22_animal_2_L_SigOutput
day14L = signal_output_mat{1,1};
clear signal_output_mat
load 2019_01_22_animal_2_R_SigOutput
day14R = signal_output_mat{1,1};
clear signal_output_mat
load 2019_01_28_animal_2_single_L_SigOutput
day21L = signal_output_mat{1,1};
clear signal_output_mat
load 2019_01_28_animal_2_single_R_SigOutput
day21R = signal_output_mat{1,1};

fps = 500;
frames = signal_output_mat{3,1};
if iscell(frames) == 1 || isempty(frames)
    frames = 60000;
end
t_full = 1/fps:1/fps:frames/fps;
t = t_full(1:2:end-5);

%% plotting
figure()
subplot 421
title('Right Side Eye')
plot(t,day0R);xlim([0 120]);
ylabel('Length [px]')
subplot 422
title('Left Side Eye')
plot(t,day0L);xlim([0 120]);
subplot 423
plot(t,day2R);xlim([0 120]);
ylabel('Length [px]')
subplot 424
plot(t,day2L);xlim([0 120]);
subplot 425
plot(t,day14R);xlim([0 120]);
ylabel('Length [px]')
subplot 426
plot(t,day14L);xlim([0 120]);
subplot 427
plot(t,day21R);xlim([0 120]);
ylabel('Length [px]')
subplot 428
plot(t,day21L);xlim([0 120]);
subplot 421
title('Right Side Eye')
subplot 422
title('Left Side Eye')

