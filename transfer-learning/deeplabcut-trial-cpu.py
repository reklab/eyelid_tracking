# -*- coding: utf-8 -*-
"""
Created on Thu Jan 17 14:19:41 2019

@author: gtsror
"""
import matplotlib
import deeplabcut
import tensorflow as tf
import os
from pathlib import Path


path_config_file = os.path.join(os.getcwd(),'Reaching-Mackenzie-2018-08-30/config.yaml')
deeplabcut.load_demo_data(path_config_file)

deeplabcut.check_labels(path_config_file)
deeplabcut.create_training_dataset(path_config_file)
deeplabcut.train_network(path_config_file, shuffle=1)
deeplabcut.evaluate_network(path_config_file,plotting=True)

# creating the video path
videofile_path = '/Reaching-Mackenzie-2018-08-30/videos/MovieS2_Perturbation_noLaser_compressed.avi'
print("Start Analyzing the video!")
deeplabcut.analyze_videos(path_config_file,[videofile_path])
deeplabcut.create_labeled_video(path_config_file,[videofile_path])

