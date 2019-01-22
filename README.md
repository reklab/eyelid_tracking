# Eyelid Tracking
Codes for eye_lid tracking application developed in Guy Tsor's master's thesis.
Github @guyts.


# DeepLabCut installation and setup on a Windows 10 environment

To get a Python friendly environment set up, please follow the steps below. This will guide you through getting DLC installed on your Windows machine from scratch [was tested on Windows 10 PC].

## Step 1: Setting up Python

### Setting up Anaconda:

To set up your Python 3.7 environment, go to the [Anaconda Page](https://www.anaconda.com/download/) and download the latest version to suit your machine.
Go through the steps one-by-one, and install with the recommneded settings. You can use [this](https://www.datacamp.com/community/tutorials/installing-anaconda-windows) as a reference. There's no need to install VS Code, unless that's your preferred method of coding.

### Making sure it works:

In your Start Menu, open Anaconda Prompt. Type in `conda --version` and `python --version` to make sure it was installed properly with latest versions available. 
You can also type in `conda list` to get a list of all the packages currently installed. 

## Step 2: Setting up DeepLabCut:

This process was done mostly based on the documnetation provided in the [DLC Installation Guide](https://github.com/AlexEMG/DeepLabCut/blob/master/docs/installation.md), with minor adjustments and changes following local errors we received. You can follow their guidance for the official version, or try the following steps:

Start by forking DLC or downloading the library to your PC. Locate the file named `dlc-windowsCPU.yaml` in your PC and copy this directory address.

# Creating the environment:

Open the Anaconda Prompt (via start menu), and create an Anaconda Environment. Before doing so, make sure you are in the correct directory

