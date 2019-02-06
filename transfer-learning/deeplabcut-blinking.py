# -*- coding: utf-8 -*-
"""
Created on Fri Jan 18 14:03:23 2019

@author: gtsror
"""

# Loading deeplabcut
# notice the warning re Tk vs Qt

import deeplabcut
import matplotlib

print("DLC version used: ", deeplabcut.__version__)

# Setting up the blink analysis project;
# This is trained on 2 videos from the March 2018 recording, as well as 3 videos from January 2019 recordings
# In total, each video generated ~30 frames, so around 150 total frames were used for training.

# Creating the project:
task = 'blinking' 
sides = 'lr' # Enter the name of the experimenter

# Directory and filenames of videos used for training:
# NOTE: all MATLAB generated videos in this library have been recorded at ~500fps, but 
# were generated at ~150fps by MATLAB due to ffmpeg issues. This doesn't affect the outputs
# simply the generation of a time series vector later on.

training_videos = ['videos/2018_03_08_animal_1_video_1b.mp4',
                   'videos/2018_03_09_animal_3_video_2.mp4',
                   'videos/2019_01_07_animal_2.mp4',
                   'videos/2019_01_07_animal_3.mp4'
                   ]

# Defining the working directory within the current directory. This will open a new folder for the project.
# All new training models, videos, and analyses will be carried out here.
# This also changes the current working directory (supposed to, not sure if happens in practice)

deeplabcut.create_new_project(task, sides, training_videos, working_directory='dlc-blinking',copy_videos=True)
path_config_file = '/dlc-blinking/blinking-lr-2019-02-06/config.yaml' # Enter the path of the config file that was just created from the above step (check the folder)

# if we plan on adding new videos to the project, we should use the following option:
#deeplabcut.add_new_videos(config_path,[‘full path of video X’, ‘full path of video X+1’],copy_videos=True/False)
deeplabcut.add_new_videos(path_config_file,['videos/2019_01_07_animal_5.mp4'],copy_videos=True)

# Config file is now written.
# Go to config file for changing the bodyparts.
# As default we are monitoring both left-right eyes inner and outer points
# In addition, make sure the cropped frames for each video are correct indeed


# extracting frames, uniformly from the videos provided during setup. 
# Note, in versions 2.0.4 and earlier, please set opencv to False in case the extraction is not from 0 to 100
# but something in between.
# the matplotlib inline is required to keep all plots within the console
%matplotlib inline
deeplabcut.extract_frames(path_config_file, 'automatic', 'uniform', crop=True, checkcropping=True, opencv=False) #there are other ways to grab frames, such as by clustering 'kmeans'; please see the paper. 

# go to the labeled data folder, and remove the first image for each folder. It's usually uncropped.
# we can now label the frames
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
videofile_path = ['dlc-blinking/an3_vid2_full/eyes_only-Guy-2019-01-25/videos/animal_3_video_2_150fps_correct.mp4',
                  'dlc-blinking/an3_vid2_full/eyes_only-Guy-2019-01-25/videos/march_8_animal_1_video_150fps_correct.mp4'] #Enter the list of videos to analyze.
videofile_path = ['dlc-blinking/an3_vid2_full/eyes_only-Guy-2019-01-25/videos/crush_19_01_07_animal_3.mp4']
deeplabcut.analyze_videos(path_config_file,videofile_path,save_as_csv=True)


deeplabcut.create_labeled_video(path_config_file, ['D:\\dlc-blinking\\an3_vid2_full\\eyes_only-Guy-2019-01-25\\videos\\crush_19_01_07_animal_3.mp4'], save_frames=True)
deeplabcut.create_labeled_video(path_config_file, ['D:\\dlc-blinking\\an3_vid2_full\\eyes_only-Guy-2019-01-25\\videos\\march_8_animal_1_video_150fps_correct.mp4'], save_frames=True)

%matplotlib notebook #for making interactive plots.
deeplabcut.plot_trajectories(path_config_file,videofile_path)


# TICTOCS:
# training - up to 72/96 hours
# analyzing - 45 minutes and 1.5 hours
# labeling - 25 minutes and 50 minutes