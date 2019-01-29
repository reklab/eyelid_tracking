# -*- coding: utf-8 -*-
"""
Created on Mon Jan 21 14:38:29 2019

@author: gtsror
"""

# Reading the output data into python using h5

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import scipy.io

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
    
    axes[0].set_title("Left Eye Output", fontsize=2)
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
filename2 = 'march_8_animal_1_video_150fps_correctDeepCut_resnet50_eyes_onlyJan25shuffle1_350000' 

df = pd.read_csv(filename1)

# reorganizing dataframe with column names etc
df.columns = (df.iloc[0] + '_' + df.iloc[1])
df = df.iloc[2:].reset_index(drop=True)
df = df.apply(pd.to_numeric)

# Left eye processing:
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

plot_double_output(output_df)


## IMPORTING OLD DATA TO SUPERIMPOSE FOR COMPARISON

old_L = scipy.io.loadmat('file.mat')

