# -*- coding: utf-8 -*-
"""
Created on Mon Feb  4 16:26:09 2019

@author: gtsror
"""


# DLC Set up on blinking

import deeplabcut
import matplotlib

task='whisk_only' # Enter the name of your experiment Task
experimenter='Guy' # Enter the name of the experimenter
video=['videos/animal_3_video_2_150fps_correct.mp4', 'videos/crush_19_01_07_animal_3.mp4'] # Enter the paths of your videos you want to grab frames from.

deeplabcut.create_new_project(task,experimenter,video, working_directory='dlc-blinking/whisk',copy_videos=True) #change the working directory to where you want the folders created.

%matplotlib inline
path_config_file = '/dlc-blinking/whisk/whisk_only-Guy-2019-02-01/config.yaml' # Enter the path of the config file that was just created from the above step (check the folder)
deeplabcut.extract_frames(path_config_file,'automatic','uniform',crop=True, checkcropping=True, opencv=False) #there are other ways to grab frames, such as by clustering 'kmeans'; please see the paper. 


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
videofile_path = ['dlc-blinking/an3_vid2_full/eyes_only-Guy-2019-01-25/videos/animal_3_video_2_150fps_correct.mp4',
                  'dlc-blinking/an3_vid2_full/eyes_only-Guy-2019-01-25/videos/march_8_animal_1_video_150fps_correct.mp4'] #Enter the list of videos to analyze.
videofile_path = ['dlc-blinking/whisk/whisk_only-Guy-2019-02-01/videos/crush_19_01_07_animal_3.mp4',
                  'dlc-blinking/whisk/whisk_only-Guy-2019-02-01/videos/animal_3_video_2_150fps_correct.mp4']
deeplabcut.analyze_videos(path_config_file,videofile_path,save_as_csv=True)


deeplabcut.create_labeled_video(path_config_file, ['D:\\dlc-blinking\\an3_vid2_full\\whisk_only-Guy-2019-02-01\\videos\\crush_19_01_07_animal_3.mp4'], save_frames=True)
deeplabcut.create_labeled_video(path_config_file, ['D:\\dlc-blinking\\whisk\\whisk_only-Guy-2019-02-01\\videos\\animal_3_video_2_150fps_correct.mp4'], save_frames=True)

%matplotlib notebook #for making interactive plots.
deeplabcut.plot_trajectories(path_config_file,videofile_path)


# TICTOCS:
# training - up to 72/96 hours
# analyzing - 45 minutes and 1.5 hours
# labeling - 25 minutes and 50 minutes