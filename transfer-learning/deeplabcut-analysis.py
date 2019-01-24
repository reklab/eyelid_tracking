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

def plot_output(df):
       
    sns.set_style("whitegrid")
    sns.lineplot('time','minor_axis',data=df)
    plt.ylabel('Minor Axis Length [pixels]', fontsize=16)
    plt.xlabel('Time [seconds]', fontsize=16)

def minor_length(df):
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

plot_output(output_df)
    

