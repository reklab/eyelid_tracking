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
