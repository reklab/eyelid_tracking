# Eyelid Tracking
Codes for eye_lid tracking application developed in Guy Tsor's master's thesis.
[Github @guyts](https://github.com/guyts).

The code in this library contains two very different approaches to eyelid tracking - one (implemented in MATLAB) uses the active contour algorithm to track contours throuhout a video, while the other (implemented in Python) uses a transfer learning framework (DeepLabCut 2) to train a classifier to track the eye in a video recording.

# METHOD 1: Traditional Image Processing Using Active Contours

One of two options available to run this method, either from a MATLAB command line or using the executable. 

Notes on the requirements to make the program work properly:

* Both methods are using single frames, reading one frame at a time, rather than processing the entire video. In case you only have the video, there is an option during set up to convert the video to single frames.
* Both methods assume frame type is .jpeg
* Both methods can handle any file name, however the frame number must be indicated at the very end, just before the suffix (example: 'video-rec-january-1005.jpg' is a valid file name, compared to '1005-video-rec-january.jpg')

In case where your system has slightly different set up, making minor adjustments to the MATLAB files can be easily done to fit different file types or naming conventions.

The executable option should be used in case no MATLAB is set up on your system, or if your recording system is similar to that described above and in the [relevant paper](https://www.researchgate.net/publication/328984007_Eyelid_and_Blink_Tracking_in_an_Animal_Model_of_Facial_Palsy).


## Run .exe file

Install the package available here.


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

This process was done mostly based on the documnetation provided in the [DLC Installation Guide](https://github.com/AlexEMG/DeepLabCut/blob/master/docs/installation.md). If you installed Anaconda from scratch and had no prior environments set - the documentation provided above should work perfectly okay.

In case you had additional libraries installed beforehand, you might need to make minor adjustments and changes in case you get errors while installing DLC or TensorFlow.

# Creating the environment:

Start by downloading the library to your PC. Locate the file named `dlc-windowsCPU.yaml` in your PC and copy this directory address.

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

When installing DLC, you might get an error message that looks like the following:

`jupyter-console 6.0.0 has requirement prompt_toolkit<2.1.0,>=2.0.0, but you'll have prompt-toolkit 1.0.15 which is incompatible.`

In this case, simply use `pip install PACKAGENAME==VER.SION` to install the version required to have DLC run properly. For example, for the error above, you could install the relevant version of `prompt-toolkit`:

`pip install prompt_toolkit==2.0.1`

This will install a version that is compatiable with DLC.

