# -*- coding: utf-8 -*-
"""
Created on Fri Jan 18 14:03:23 2019

@author: gtsror
"""

# DLC Set up on blinking

import deeplabcut

task='Looking' # Enter the name of your experiment Task
experimenter='Guy' # Enter the name of the experimenter
video=['videos/an3_vid2_150fps.mp4'] # Enter the paths of your videos you want to grab frames from.

deeplabcut.create_new_project(task,experimenter,video, working_directory='/dlc-blinking',copy_videos=True) #change the working directory to where you want the folders created.

%matplotlib inline
path_config_file = '/dlc-blinking/Looking-Guy-2019-01-18/config.yaml' # Enter the path of the config file that was just created from the above step (check the folder)
deeplabcut.extract_frames(path_config_file,'automatic','uniform',crop=True, checkcropping=True) #there are other ways to grab frames, such as by clustering 'kmeans'; please see the paper. 

# changed the cropping dimensions in the config.yaml file
%gui wx
deeplabcut.label_frames(path_config_file)

# Lables have now been created

deeplabcut.check_labels(path_config_file) #this creates a subdirectory with the frames + your labels
# Reviewed the labels, the seem to be ok

# Downloading the ResNets dataset:
deeplabcut.create_training_dataset(path_config_file)

# Training the dataset
deeplabcut.train_network(path_config_file)

# Evaluating the results
deeplabcut.evaluate_network(path_config_file)

# Analyzing video
videofile_path = ['dlc-blinking/an3_vid2/videos/an3_vid2_150fps.mp4'] #Enter the list of videos to analyze.
deeplabcut.analyze_videos(path_config_file,videofile_path,save_as_csv=True)

deeplabcut.create_labeled_video(path_config_file, ['D:\\dlc-blinking\\an3_vid2\\videos\\an3_vid2_150fps.mp4'], save_frames=True)

%matplotlib notebook #for making interactive plots.
deeplabcut.plot_trajectories(path_config_file,videofile_path)