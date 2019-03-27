% This file is used for analysis of all the results

[~,~,data] = xlsread('results-summary.csv')

animal_1_corr = [];
animal_2_corr = [];
animal_3_corr = [];
animal_4_corr = [];
animal_6_corr = [];

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
data_control = [animal_3_corr, animal_4_corr, animal_6_corr]
SEM = std(data_control)/sqrt(length(data_control));% Standard Error
ts = tinv([0.025  0.975],length(data_control)-1);      % T-Score
CI = mean(data_control) + ts*SEM;                      % Confidence Intervals



day_post_injury = [0,2,7,10,15,21,30];


figure()
plot(day_post_injury, animal_1_corr,'linewidth',2,'color','blue')
hold on;
plot(day_post_injury(1:end-1), animal_2_corr,'linewidth',2,'color','r')
grid on;

if interest == 'CCC'
    ylabel('Concordance Correlation Coefficient')
else
    ylabel('Pearson Correlation Coefficient')
end

xlabel('Post Operative Days');
title('Animals left-right eye size correlation, over time');

% plotting the control and the CI:
x_axis=[day_post_injury(1),day_post_injury(end)];
x_plot = [x_axis, fliplr(x_axis)];
y_plot=[CI(1), CI(1), CI(2), CI(2)];

hold on;
plot(x_axis,[mean(data_control) mean(data_control)],'color','g','linewidth',3);

fill(x_plot, y_plot, 1,'facecolor', 'green', 'edgecolor', 'none', 'facealpha', 0.2);