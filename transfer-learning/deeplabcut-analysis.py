# -*- coding: utf-8 -*-
"""
Created on Mon Jan 21 14:38:29 2019

@author: gtsror
"""

# This file works well as of April 2019

# Reading the output data into python using h5

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from plotly.offline import download_plotlyjs, init_notebook_mode, plot, iplot
import plotly.graph_objs as go
from plotly import tools

def plot_single_output(df):
       
    sns.set_style("whitegrid")
    sns.lineplot('time','minor_axis',data=df)
    plt.ylabel('Minor Axis Length [pixels]', fontsize=16)
    plt.xlabel('Time [seconds]', fontsize=16)

def plot_double_output(df):
       
    fig, axes = plt.subplots(2, 1)
    sns.set_style("whitegrid")
    sns.lineplot('time','minor_axis_L',data=df,ax=axes[0])
    sns.lineplot('time','minor_axis_R',data=df,ax=axes[1])
    
    axes[0].set_title("Left Eye Output", fontsize=20)
    axes[1].set_title("Right Eye Output", fontsize=20)
    axes[0].set_xlabel("Time [seconds]", fontsize=16)
    axes[1].set_xlabel("Time [seconds]", fontsize=16)
    axes[0].set_ylabel("Minor Axis Length [pixels]", fontsize=16)
    axes[1].set_ylabel("Minor Axis Length [pixels]", fontsize=16)
    
def minor_length(df):
    minor_axis_L = []
    minor_axis_R = []
    for index,row in df.iterrows():
        x_l_out = row['left-eye-outer_x']
        y_l_out = row['left-eye-outer_y']
        x_l_in = row['left-eye-inner_x']
        y_l_in = row['left-eye-inner_y']
        x_r_out = row['right-eye-outer_x']
        y_r_out = row['right-eye-outer_y']
        x_r_in = row['right-eye-inner_x']
        y_r_in = row['right-eye-inner_y']
        minor_axis_L.append(calc_euc(x_l_out,y_l_out,x_l_in,y_l_in))
        minor_axis_R.append(calc_euc(x_r_out,y_r_out,x_r_in,y_r_in))
    return minor_axis_L, minor_axis_R

def minor_length_single(df):
    minor_axis  = []
    for index,row in df.iterrows():
        x1 = row['eye-left-edge_x']
        y1 = row['eye-left-edge_y']
        x2 = row['eye-right-edge_x']
        y2 = row['eye-right-edge_y']
        minor_axis.append(calc_euc(x1,y1,x2,y2))
    return minor_axis

def calc_euc(x1,y1,x2,y2):
    dist = np.sqrt(np.power(x1-x2,2)+np.power(y1-y2,2))
    return dist

## FOLLOWING SECTION HANDLES A SINGLE EYE VIDEOS

filename = 'an3_vid2_150fpsDeepCut_resnet50_LookingJan18shuffle1_400000.csv'
filename = '2019_01_09_animal_2DeepCut_resnet50_blinkingFeb7shuffle1_360000.csv'


df = pd.read_csv(filename)

# reorganizing dataframe
df.columns = (df.iloc[0] + '_' + df.iloc[1])
df = df.iloc[2:].reset_index(drop=True)
df = df.apply(pd.to_numeric)

# relevant coordinates dataframe
df = df.drop(['eye-top-point_x', 'eye-top-point_y',
       'eye-top-point_likelihood', 'eye-bottom-point_x', 'eye-bottom-point_y',
       'eye-bottom-point_likelihood'], axis=1)

# generate minor axis length:
minor_axis = minor_length(df)

# plotting (using seaborn)
frames = df.bodyparts_coords+1 # getting the frames 
fps = 500

# input into a single dataframe
d = {'frame': frames,
     'time': frames/fps,
     'minor_axis': minor_axis, 
     }
output_df = pd.DataFrame(d)

plot_single_output(output_df)
    
## FOLLOWING SECTION HANDLES DOUBLE EYES VIDEOS

filename1 = 'animal_3_video_2_150fps_correctDeepCut_resnet50_eyes_onlyJan25shuffle1_350000.csv'
filename2 = 'march_8_animal_1_video_150fps_correctDeepCut_resnet50_eyes_onlyJan25shuffle1_350000.csv' 
filename2 = '2019_01_07_animal_1DeepCut_resnet50_blinkingFeb7shuffle1_360000.csv'
filename2 = '2019_02_07_animal_4DeepCut_resnet50_blinkingFeb7shuffle1_360000.csv' 
filename2 = '2019_01_14_animal_1DeepCut_resnet50_blinkingFeb7shuffle1_360000.csv'
filename2 = '2019_01_14_animal_2DeepCut_resnet50_blinkingFeb7shuffle1_360000.csv'
filename2 = '2019_01_17_animal_1DeepCut_resnet50_blinkingFeb7shuffle1_360000.csv'
filename2 = '2019_01_17_animal_2DeepCut_resnet50_blinkingFeb7shuffle1_360000.csv'
filename2 = '2019_01_22_animal_1DeepCut_resnet50_blinkingFeb7shuffle1_360000.csv'
filename2 = '2019_01_22_animal_2DeepCut_resnet50_blinkingFeb7shuffle1_360000.csv'
filename2 = '2019_01_28_animal_1DeepCut_resnet50_blinkingFeb7shuffle1_360000.csv'
filename2 = '2019_01_28_animal_2DeepCut_resnet50_blinkingFeb7shuffle1_360000.csv'
filename2 = '2019_02_07_animal_1DeepCut_resnet50_blinkingFeb7shuffle1_360000.csv'
filename2 = '2019_02_07_animal_2DeepCut_resnet50_blinkingFeb7shuffle1_360000.csv'
filename2 = '2019_02_07_animal_3DeepCut_resnet50_blinkingFeb7shuffle1_360000.csv'
filename2 = '2019_02_07_animal_6DeepCut_resnet50_blinkingFeb7shuffle1_360000.csv'


df = pd.read_csv(filename2)

# reorganizing dataframe with column names etc
df.columns = (df.iloc[0] + '_' + df.iloc[1])
df = df.iloc[2:].reset_index(drop=True)
df = df.apply(pd.to_numeric)

# eye processing:
minor_axis_L, minor_axis_R = minor_length(df)

# plotting (using seaborn)
frames = df.bodyparts_coords+1 # getting the frames 
fps = 500

# input into a single dataframe
d = {'frame': frames,
     'time': frames/fps,
     'minor_axis_L': minor_axis_L, 
     'minor_axis_R': minor_axis_R,
     }
output_df = pd.DataFrame(d)

output_df.to_csv(filename2[0:19]+'_dlc.csv',index=False,)

plot_double_output(output_df)

## VALIDATION ANALYSIS FOR SECTIONS OF VIDEOS

mat_output = pd.read_csv('output-files/validation/matfiles/2019_02_07_animal_4_R_SigOutput.csv',header=None)
mat_validation = pd.read_csv('output-files/validation/valfiles/F7A4R_R_ValOutput.csv',header=None)
dlc_output = pd.read_csv('output-files/validation/dlcfiles/2019_02_07_animal_4_dlc.csv')

# input the desired start and end time:

begin_time = 61;
end_time = 63.5;

begin_fr = begin_time*fps
end_fr = end_time*fps
'''
# relevant frames from validation dataset
begin_fr_val = begin_time*fps*2
end_fr_val = end_time*fps*2
# relevant frames from matlab output 
begin_fr_mat = begin_time*fps
end_fr_mat = end_time*fps
# relevant frames from dlc output:
'''
# dropping any irrelevant portions from all 3 inputs:

val_data = mat_validation.iloc[begin_fr:]
dlc_data = dlc_output.iloc[begin_fr:begin_fr+len(val_data)]
mat_data = mat_output.iloc[begin_fr:begin_fr+len(val_data)]

time = dlc_data.time

# Create a view with all 3 plots using plotly:

trace_dlc = go.Scatter(
    x = time[0:-1],
    y = dlc_data.minor_axis_R,
    mode = 'lines',
    name = 'ML Approach',
    marker = dict(
            color = 'blue'
            )
)
trace_mat = go.Scatter(
    x = time[0:-1],
    y = mat_data.iloc[:,0],
    mode = 'lines',
    name = 'Active Contour Approach',
    marker = dict(
            color = 'brown'
            )
)
trace_val = go.Scatter(
    x = time[0:-1],
    y = val_data.iloc[:,0],
    mode = 'lines',
    name = 'Manual Validation',
    marker = dict(
            color = 'green'
            )
)

fig = tools.make_subplots(rows=1, cols=1)
fig.append_trace(trace_dlc, 1, 1)
fig.append_trace(trace_mat, 1, 1)
fig.append_trace(trace_val, 1, 1)

init_notebook_mode(connected=True)

fig['layout'].update(height=800, width=1200, title='Deep Learning vs. Active Contour vs. Manual')

plot(fig)

# calculating score between DLC and Validation:


## IMPORTING OLD DATA TO SUPERIMPOSE FOR COMPARISON

mat_output = pd.read_csv('output-files/validation/matfiles/2019_01_07_animal_1_R_SigOutput.csv',header=None)
mat_validation = pd.read_csv('output-files/validation/valfiles/J7A1R_R_ValOutput.csv',header=None)

# matching signal lengths by dropping endings of Python generated files:

diff = len(df)-len(mat_output)
#dlc_output = df.copy(df.drop(df.tail(diff).index,inplace=True))
mat_validation.drop(mat_validation.tail(len(mat_validation)-len(mat_output)).index,inplace=True)

# OR removing directly from the minor axis vector list
minor_axis_L_adj = minor_axis_L[0:-diff]

# Create a view with all 3 plots using plotly:

trace_dlc = go.Scatter(
    x = frames[0:-1],
    y = minor_axis_L_adj,
    mode = 'lines',
    name = 'ML Approach',
    marker = dict(
            color = 'blue'
            )
)
trace_contour = go.Scatter(
    x = frames[0:-1],
    y = mat_output.iloc[:,0],
    mode = 'lines',
    name = 'Active Contour Approach',
    marker = dict(
            color = 'brown'
            )
)
trace_manual = go.Scatter(
    x = frames[0:-1],
    y = mat_validation.iloc[:,0],
    mode = 'lines',
    name = 'Manual Validation',
    marker = dict(
            color = 'green'
            )
)

fig = tools.make_subplots(rows=1, cols=1)
fig.append_trace(trace_dlc, 1, 1)
fig.append_trace(trace_contour, 1, 1)
fig.append_trace(trace_manual, 1, 1)

init_notebook_mode(connected=True)

fig['layout'].update(height=800, width=1200, title='Deep Learning vs. Active Contour vs. Manual')

plot(fig)

# Calculate errors:
