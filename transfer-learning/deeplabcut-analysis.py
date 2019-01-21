# -*- coding: utf-8 -*-
"""
Created on Mon Jan 21 14:38:29 2019

@author: gtsror
"""

# Reading the output data into python using h5

import pandas as pd
import numpy as np

filename = 'an3_vid2_150fpsDeepCut_resnet50_LookingJan18shuffle1_400000.csv'
df = pd.read_csv(filename)


# reorganizing dataframe
df.columns = df.iloc[0]
df.reindex(df.index.drop(0))

stri = [df.iloc[0,:], df.iloc[1,:]]

stri[1].str.cat(sep='_')
