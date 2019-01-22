# Eyelid Tracking
Codes for eye_lid tracking application developed in Guy Tsor's master's thesis.
Github @guyts.

The code in this library contains two very different approaches to eyelid tracking - one (implemented in MATLAB) uses the active contour algorithm to track contours throuhout a video, while the other (implemented in Python) uses a transfer learning framework (DeepLabCut 2) to train a classifier to track the eye in a video recording.

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

Start by downloading the library to your PC. Locate the file named `dlc-windowsCPU.yaml` in your PC and copy this directory address.

# Creating the environment:

Open the Anaconda Prompt (via start menu), and create an Anaconda Environment. Before doing so, make sure you are in the correct directory (the one containing the `.yaml` file mentioned earlier - this file will provide the configuration details for the environment.
In the prompt, create the environment:'

`conda env create -f dlc-windowsCPU.yaml`

Once that's done, activate the environment:

`activate dlc-windowsCPU`

# Installing DeepLabCut:

If all is right - you can now install DeepLabCut using `pip`:

`pip install deeplabcut`

Followed by:

`pip install -U wxPython`

# Installing TensorFlow:

Documentation on the official DLC page suggest to install a specific TensorFlow version (`pip install --ignore-installed tensorflow==1.10`), however I found it to not work in my environment. Instead, try installing the latest version of TF as follows:

`pip install --ignore-installed tensorflow`

This will install a later version (1.12 in the time I'm writing this document), which seemed to work perfectly fine.

# Possible errors and problems, and how to deal with them:

When installing DLC, you might get the following message:
`jupyter-console 6.0.0 has requirement prompt_toolkit<2.1.0,>=2.0.0, but you'll have prompt-toolkit 1.0.15 which is incompatible.`

In this case,

