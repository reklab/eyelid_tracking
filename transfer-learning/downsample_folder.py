# -*- coding: utf-8 -*-
"""
Created on Mon Apr  8 10:15:24 2019

@author: gtsror
"""

# downsampling script to be used with DLC2

import os

all_files = os.listdir()
file_prefix_list = []

for item in all_files:
    if item.endswith(".jpg"):
        tmp_split = item.split('_')
        file_no = int(tmp_split[-1][0:-4]) #discarding the jpg suffix
        file_prefix_list.append(file_no)
    
# sorting the list:
file_prefix_list.sort()

# picking odd ones to delete:
even_files_to_del = file_prefix_list[1::2]

# running on items in directory and deleting every other one:
del_ind = 0
length = len(all_files)
for ind,item in enumerate(all_files):
    if item.endswith(".jpg"):
        print(ind/length*100, '%' , end="\r")
        item_no = int(item.split('_')[-1][0:-4])
        del_no = even_files_to_del[del_ind]
        if item_no == del_no:
            # If this condition is met, we want to discard of the file and advance the deleted index by one
            os.remove(item)
            del_ind +=1
            
        

            
        
        


